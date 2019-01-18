//
//  VCMediaPlayer.m
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/12.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import "VCMediaPlayer.h"
#import "MediaPlayInfo.h"
#import "VCAssetResourceLoaderHandler.h"
#import "VCMediaDownloadManager.h"
#import "VCFileHandle.h"

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, VCMediaPlayerPlayStyle) {
    VCMediaPlayerPlayStyleLoop,
    VCMediaPlayerPlayStyleSingle,
    VCMediaPlayerPlayStyleRamdom,
};

static NSString * const kPlayerItemLoadedTimeRanges = @"loadedTimeRanges";
static NSString * const kPlayerItemSrBufferEmty = @"playbackBufferEmpty";
static NSString * const kPlayerItemStatus = @"status";
static NSString * const kPlayerRate = @"rate";

@interface  VCMediaPlayer()<AVAssetResourceLoaderDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) id timeObserver;

@property (nonatomic, copy) NSArray<id<VCMediaPlayInfoProtocol>> *playInfos;

@property (nonatomic, strong) AVPlayerItem *currentPlayerItem;
@property (nonatomic, strong) MediaPlayInfo *currentPlayInfo;
@property (nonatomic, strong) VCAssetResourceLoaderHandler *resourceLoaderHandler;
@property (nonatomic, assign, readonly) CGFloat currentPlayDuration;

@property (nonatomic, assign) VCMediaPlayerPlayStyle playerStyle;
@property (nonatomic, assign, readwrite) VCMediaPlayerPlayStatus playStatus;

@end

@implementation VCMediaPlayer

/**
 初始化
 
 @param playInfos 播放列表
 @param containerView 播放影片要貼上的View
 */
- (instancetype)initWithPlayInfos:(NSArray<id<VCMediaPlayInfoProtocol>> *)playInfos containerView:(nullable UIView *)containerView {
    return [self initWithPlayInfos:playInfos containerView:containerView offset:0];
}

/**
 初始化
 
 @param playInfos 播放列表
 @param offset 從哪一筆開始播放
 @param containerView 播放影片要貼上的View
 */
- (instancetype)initWithPlayInfos:(NSArray<id<VCMediaPlayInfoProtocol>> *)playInfos containerView:(UIView *)containerView offset:(NSInteger)offset {
    
    NSAssert(!(offset < 0 || offset > self.playInfos.count - 1), @"歌曲播放位置不合法");
    NSAssert(playInfos.count > 0, @"播放列表不為空");
    
    if (self = [super init]) {
        _playInfos = playInfos;
        _currentPlayInfo = playInfos[offset];
        _containerView = containerView;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        [self setupPlayer];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

#pragma mark - public

/**
 播放
 */
- (void)play {
    if (self.playStatus == VCMediaPlayerPlayStatusPause || self.playStatus == VCMediaPlayerPlayStatusWatting) {
        [self.player play];
    }
}

/**
 暫停播放
 */
- (void)pause {
    if (self.playStatus == VCMediaPlayerPlayStatusPlay || self.playStatus == VCMediaPlayerPlayStatusBuffer) {
        [self.player pause];
    }
}

/**
 停止播放
 */
- (void)stop {
    if (self.playStatus == VCMediaPlayerPlayStatusPlay || self.playStatus == VCMediaPlayerPlayStatusBuffer) {
        [self.player pause];
    }
}

/**
 播放下一首
 */
- (void)playNext {
    [self.resourceLoaderHandler.manager cancelDownload];
    MediaPlayInfo *nextPlayInfo = self.playInfos[[self fetchNextPlayIndex]];
    [self playWithUrl:nextPlayInfo];
}

/**
 播放前一首
 */
- (void)playPrevious {
    [self.resourceLoaderHandler.manager cancelDownload];
    MediaPlayInfo *previousPlayInfo = self.playInfos[[self fetchPreviousPlayIndex]];
    [self playWithUrl:previousPlayInfo];
}

-(void)playWithUrl:(MediaPlayInfo *)playInfo {
    
    [self removeObserverWithPlayerItem:self.currentPlayerItem];
    [self removePlayerTimeObserverIfNeeded];
    
    self.currentPlayInfo = playInfo;
    NSURL *fileURL = [VCFileHandle URLCacheFileExistsWithPath:self.currentPlayInfo.cacheMediaDownloadPath];
    if (fileURL) {
        self.currentPlayerItem = [[AVPlayerItem alloc] initWithURL:fileURL];
    } else {
        self.resourceLoaderHandler = [VCAssetResourceLoaderHandler resourceLoaderHandlerWithMediaInfo:self.currentPlayInfo];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self mediaDownloadUrl] options:nil];
        [asset.resourceLoader setDelegate:self.resourceLoaderHandler queue:dispatch_get_main_queue()];
        self.currentPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    }

    
    [self addObserverWithPlayerItem:self.currentPlayerItem];
    [self addPlayerObserver];
    
    [self.player replaceCurrentItemWithPlayerItem:self.currentPlayerItem];
    [self.player play];
    
    if ([self.delegate respondsToSelector:@selector(mediaPlayer:didFinishedWithNextPlayInfo:)]) {
        [self.delegate mediaPlayer:self didFinishedWithNextPlayInfo:self.currentPlayInfo];
    }
}

/**
 快轉到想要的進度
 @progress 進度值介於0~1
 */
- (void)seekWithProgress:(CGFloat)progress {
    progress = progress > 1 ? 1 : progress;
    progress = progress < 0 ? 0 : progress;
    
    [self.player pause];
    CGFloat time = self.currentPlayDuration * progress;
    [self.player seekToTime:CMTimeMake(time, 1)];
    [self.player play];
}

- (void)shutdown {
    [self removeObserverWithPlayerItem:self.currentPlayerItem];
    [self removePlayerTimeObserverIfNeeded];
    [self.player pause];
    
    self.player = nil;
    self.playInfos = nil;
    self.currentPlayerItem = nil;
    self.currentPlayInfo = nil;
}

#pragma mark - private

/**
 初始化AVPlayer
 */
- (void)setupPlayer {
    
    NSURL *fileURL = [VCFileHandle URLCacheFileExistsWithPath:self.currentPlayInfo.cacheMediaDownloadPath];
    if (fileURL) {
        self.currentPlayerItem = [[AVPlayerItem alloc] initWithURL:fileURL];
    } else {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self mediaDownloadUrl] options:nil];
        self.resourceLoaderHandler = [VCAssetResourceLoaderHandler resourceLoaderHandlerWithMediaInfo:self.currentPlayInfo];
        [asset.resourceLoader setDelegate:self.resourceLoaderHandler queue:dispatch_get_main_queue()];
        self.currentPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    }
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.currentPlayerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.containerView.layer.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;

    [self.containerView.layer addSublayer:self.playerLayer];
    [self addObserverWithPlayerItem:self.currentPlayerItem];
    [self addPlayerObserver];
}

/**
 新稱playerItem的Observer, 觀察播放起始狀態的改變及Loding狀態得改變
 */
- (void)addObserverWithPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem addObserver:self forKeyPath:kPlayerItemLoadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:kPlayerItemStatus options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:kPlayerItemSrBufferEmty options:NSKeyValueObservingOptionNew context:nil];
}

/**
 新稱AVPlayer的Observer, 每隔一秒回傳現在的觀看進度
 */
- (void)addPlayerObserver {
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat currentPlayTime = CMTimeGetSeconds(time);
        
        if ([weakSelf.delegate respondsToSelector:@selector(mediaPlayer:currentPlayTime:durationTime:)]) {
            [weakSelf.delegate mediaPlayer:weakSelf currentPlayTime:currentPlayTime durationTime:weakSelf.currentPlayDuration];
        }
    }];
    
    [self.player addObserver:self forKeyPath:kPlayerRate options:NSKeyValueObservingOptionNew context:nil];
}

/**
 移除playerItem的Observer
 */
- (void)removeObserverWithPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:kPlayerItemLoadedTimeRanges];
    [playerItem removeObserver:self forKeyPath:kPlayerItemStatus];
    [playerItem removeObserver:self forKeyPath:kPlayerItemSrBufferEmty];
}

/**
 移除AVPlayer的Observer
 */
- (void)removePlayerTimeObserverIfNeeded {
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    
    [self.player removeObserver:self forKeyPath:kPlayerRate];
}

/**
觀察currentPlayerItem的狀態變化
 
 kPlayerItemStatus
    1. 觸發時機為currentPlayerItem放到Player後
    2. 狀態AVPlayerItemStatusReadyToPlay為已經prepare好可以播放, 狀態AVPlayerItemStatusFailed為prepare失敗,
       狀態AVPlayerItemStatusUnknown為不清楚
 
 kPlayerItemLoadedTimeRanges
    1.觸發時機為loading進度改變時
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:kPlayerItemStatus]) {
        if ([self.delegate respondsToSelector:@selector(mediaPlayer:didChangedStatus:)]) {
            AVPlayerItemStatus itemStatus = self.currentPlayerItem.status;
            VCMediaPlayerPlayStatus playerStatus = [self playerStatusWithAVPlayerItemStatus:itemStatus];
            [self.delegate mediaPlayer:self didChangedStatus:playerStatus];
        }
        
    } else if([keyPath isEqualToString:kPlayerItemLoadedTimeRanges]) {
        if ([self.delegate respondsToSelector:@selector(mediaPlayer:bufferTime:durationTime:)]) {
            CGFloat bufferTime = [self bufferTimeIntervalWithPlayerItem:self.currentPlayerItem];
            [self.delegate mediaPlayer:self bufferTime:bufferTime durationTime:self.currentPlayDuration];
        }
        
    } else if ([keyPath isEqualToString:kPlayerItemSrBufferEmty]) {
        if ([self.delegate respondsToSelector:@selector(mediaPlayer:didChangedStatus:)]) {
            [self.delegate mediaPlayer:self didChangedStatus:VCMediaPlayerPlayStatusBuffer];
        }
    } else if ([keyPath isEqualToString:kPlayerRate]) {
        if (self.player.rate == 0.0) {
            self.playStatus = VCMediaPlayerPlayStatusPause;
            
        }else {
            self.playStatus = VCMediaPlayerPlayStatusPlay;
        }
        
        if ([self.delegate respondsToSelector:@selector(mediaPlayer:didChangedStatus:)]) {
            [self.delegate mediaPlayer:self didChangedStatus:self.playStatus];
        }
    }
}

- (VCMediaPlayerPlayStatus)playerStatusWithAVPlayerItemStatus:(AVPlayerItemStatus)itemStatus {
    NSDictionary<NSNumber *, NSNumber*> *transferDictionary
        = @{@(AVPlayerItemStatusUnknown)      : @(VCMediaPlayerPlayStatusStop),
            @(AVPlayerItemStatusFailed)       : @(VCMediaPlayerPlayStatusStop),
            @(AVPlayerItemStatusReadyToPlay)  : @(VCMediaPlayerPlayStatusPlay),
            };
    
    return [transferDictionary objectForKey:@(itemStatus)].integerValue;
}

/**
 獲取緩衝區最多可以看到哪的時間
 
 @param playerItem : playerItem
 */
- (CGFloat)bufferTimeIntervalWithPlayerItem:(AVPlayerItem *)playerItem {
    NSArray *availableTimeRanges = playerItem.loadedTimeRanges;
    CMTimeRange availableTimeRangeValue = [availableTimeRanges.firstObject CMTimeRangeValue];
    CGFloat start = CMTimeGetSeconds(availableTimeRangeValue.start);
    CGFloat duration = CMTimeGetSeconds(availableTimeRangeValue.duration);
    
    return start + duration;
    
}

/**
 獲取下一筆播放的index
 */
- (NSInteger)fetchNextPlayIndex {
    NSInteger currentPlayIndex = [self.playInfos indexOfObject:self.currentPlayInfo];
    NSInteger nextIndex = currentPlayIndex + 1;
    return nextIndex < self.playInfos.count ? nextIndex : currentPlayIndex;
}

/**
 獲取前一筆播放的index
 */
- (NSInteger)fetchPreviousPlayIndex {
    NSInteger currentPlayIndex = [self.playInfos indexOfObject:self.currentPlayInfo];
    NSInteger previousIndex = currentPlayIndex - 1;
    return previousIndex < 0 ? 0 : previousIndex;
}

- (void)playFinished {
    [self.player pause];
    [self playNext];
}


#pragma mark - accessor

- (void)setPlayerLayer:(AVPlayerLayer *)playerLayer {
    if (_playerLayer == playerLayer) {
        return;
    }
    
    [_playerLayer removeFromSuperlayer];
    _playerLayer = playerLayer;
}

- (CGFloat)currentPlayDuration {
    CGFloat seconds = CMTimeGetSeconds(self.currentPlayerItem.duration);
    if (isnan(seconds)) {
        return 0;
    }
    
    return seconds;
}

- (NSURL *)mediaDownloadUrl {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self.currentPlayInfo.mediaURL resolvingAgainstBaseURL:YES];
    components.scheme = @"streaming";
    return components.URL;
}

@end
