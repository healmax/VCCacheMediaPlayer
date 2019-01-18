//
//  VCMediaPlayer.h
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/12.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol VCMediaPlayInfoProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VCMediaPlayerPlayStatus) {
    VCMediaPlayerPlayStatusWatting,
    VCMediaPlayerPlayStatusBuffer,
    VCMediaPlayerPlayStatusPlay,
    VCMediaPlayerPlayStatusPause,
    VCMediaPlayerPlayStatusStop,
    VCMediaPlayerPlayStatusFailure,
};

@class VCMediaPlayer;

@protocol VCMediaPlayerDelegate<NSObject>

@optional
- (void)mediaPlayer:(VCMediaPlayer *)mediaPlayer didChangedStatus:(VCMediaPlayerPlayStatus)status;
- (void)mediaPlayer:(VCMediaPlayer *)mediaPlayer didFinishedWithNextPlayInfo:(id<VCMediaPlayInfoProtocol>)playInfo;
- (void)mediaPlayer:(VCMediaPlayer *)mediaPlayer bufferTime:(CGFloat)bufferTime durationTime:(CGFloat)durationTime;
- (void)mediaPlayer:(VCMediaPlayer *)mediaPlayer currentPlayTime:(CGFloat)currentPlayTime durationTime:(CGFloat)durationTime;

@end

@interface VCMediaPlayer : NSObject

@property (nonatomic, assign, readonly) VCMediaPlayerPlayStatus playStatus;
@property(nonatomic, weak) id<VCMediaPlayerDelegate> delegate;

- (instancetype)initWithPlayInfos:(NSArray<id<VCMediaPlayInfoProtocol>> *)playInfos containerView:(nullable UIView *)containerView;
- (instancetype)initWithPlayInfos:(NSArray<id<VCMediaPlayInfoProtocol>> *)playInfos containerView:(nullable UIView *)containerView offset:(NSInteger)offset;

- (void)play;
- (void)pause;
- (void)stop;
- (void)playNext;
- (void)playPrevious;
- (void)seekWithProgress:(CGFloat)progress;

- (void)shutdown;

@end

NS_ASSUME_NONNULL_END
