//
//  PlayInfoFactory.m
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/16.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import "PlayInfoFactory.h"
#import "MediaPlayInfo.h"

@implementation PlayInfoFactory

+ (NSArray<MediaPlayInfo *> *)fakeDatas {
    
    return @[[[MediaPlayInfo alloc] initWithURLString:@"http://download.lingyongqian.cn/music/ForElise.mp3"
                                                   name:@"Song2"
                                              imageName:@"2"],
             [[MediaPlayInfo alloc] initWithURLString:@"http://www.noiseaddicts.com/samples_1w72b820/2559.mp3"
                                                   name:@"Song3"
                                              imageName:@"3"],
             [[MediaPlayInfo alloc] initWithURLString:@"http://www.noiseaddicts.com/samples_1w72b820/1455.mp3"
                                                   name:@"Song4"
                                              imageName:@"4"],
             [[MediaPlayInfo alloc] initWithURLString:@"http://www.noiseaddicts.com/samples_1w72b820/2537.mp3"
                                                   name:@"Song5"
                                              imageName:@"5"],
             [[MediaPlayInfo alloc] initWithURLString:@"http://www.noiseaddicts.com/samples_1w72b820/3924.mp3"
                                                   name:@"Song6"
                                              imageName:@"6"],
             [[MediaPlayInfo alloc] initWithURLString:@"http://www.noiseaddicts.com/samples_1w72b820/3906.mp3"
                                                   name:@"Song7"
                                              imageName:@"7"],
             [[MediaPlayInfo alloc] initWithURLString:@"http://www.noiseaddicts.com/samples_1w72b820/3907.mp3"
                                                   name:@"Song8"
                                              imageName:@"8"]];
}

@end
