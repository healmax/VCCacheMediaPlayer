//
//  ViewController.m
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/12.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import "ViewController.h"
#import "VCMediaPlayer.h"
#import "MediaPlayInfo.h"
#import "PlayInfoFactory.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<VCMediaPlayerDelegate>

@property (nonatomic, strong) VCMediaPlayer *player;
@property (nonatomic, strong) NSDateComponentsFormatter *componentsFormatter;
@property (nonatomic, copy) NSArray<MediaPlayInfo *> *playInfos;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;

@property (weak, nonatomic) IBOutlet UILabel *songName;

@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupPlayer];
}

#pragma mark - Action

- (IBAction)playAction:(id)sender {
    if (self.player.playStatus == VCMediaPlayerPlayStatusPlay) {
        [self.player pause];
        
    } else if (self.player.playStatus == VCMediaPlayerPlayStatusPause){
        [self.player play];
    }
}

- (IBAction)previousButtonOnClick:(id)sender {
    [self.player playPrevious];
}

- (IBAction)nextButtonOnClick:(id)sender {
    [self.player playNext];
}

- (IBAction)silderTouchUpInside:(id)sender {
    [self.player seekWithProgress:self.slider.value];
}

#pragma mark - VCMediaPlayerDelegate

- (void)mediaPlayer:(VCMediaPlayer *)mediaPlayer didChangedStatus:(VCMediaPlayerPlayStatus)status {
    if (status == VCMediaPlayerPlayStatusPlay) {
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        
    } else if (status == VCMediaPlayerPlayStatusPause){
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else if (status == VCMediaPlayerPlayStatusStop){
        [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
        
    } else if (status == VCMediaPlayerPlayStatusBuffer){
        [self.playButton setTitle:@"Buffering" forState:UIControlStateNormal];
    }
}

- (void)mediaPlayer:(VCMediaPlayer *)mediaPlayer didFinishedWithNextPlayInfo:(id<VCMediaPlayInfoProtocol>)playInfo {
    [self updateUIWithPlayInfo:playInfo];
}

- (void)mediaPlayer:(VCMediaPlayer *)mediaPlayer bufferTime:(CGFloat)bufferTime durationTime:(CGFloat)durationTime {
    NSLog(@"buffer progress : %@", @(bufferTime/durationTime));
}

- (void)mediaPlayer:(VCMediaPlayer *)mediaPlayer currentPlayTime:(CGFloat)currentPlayTime durationTime:(CGFloat)durationTime {
    if (durationTime == 0) {
        return;
    }
    self.slider.value = currentPlayTime/durationTime;
    self.currentLabel.text = [self.componentsFormatter stringFromTimeInterval:currentPlayTime];
    self.durationLabel.text = [self.componentsFormatter stringFromTimeInterval:durationTime];
}

#pragma mark - private

- (void)setupUI {
    UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
    effe.alpha = 0.97;
    effe.frame = self.view.bounds;
    [self.view insertSubview:effe aboveSubview:self.backgroundImageView];
    
    self.albumImageView.layer.cornerRadius = 110;
    self.previousButton.layer.cornerRadius = 25;
    self.nextButton.layer.cornerRadius = 25;
    self.playButton.layer.cornerRadius = 25;
    
    [self updateUIWithPlayInfo:self.playInfos.firstObject];
}

- (void)updateUIWithPlayInfo:(id<VCMediaPlayInfoProtocol>)playInfo {
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:playInfo.mediaAlbumURL]];
    self.backgroundImageView.image = image;
    self.albumImageView.image = image;
}

- (void)setupPlayer {
    self.player = [[VCMediaPlayer alloc] initWithPlayInfos:self.playInfos containerView:nil];
    self.player.delegate = self;
    [self.player play];
}

#pragma mark - accessor

- (NSDateComponentsFormatter *)componentsFormatter {
    if (!_componentsFormatter) {
        _componentsFormatter = [[NSDateComponentsFormatter alloc] init];
        _componentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        _componentsFormatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;
        _componentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    }
    
    return _componentsFormatter;
}

- (NSArray<MediaPlayInfo *> *)playInfos {
    return [PlayInfoFactory fakeDatas];
}

@end
