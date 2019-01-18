//
//  PlayInfoFactory.h
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/16.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MediaPlayInfo;

@interface PlayInfoFactory : NSObject

+ (NSArray<MediaPlayInfo *> *)fakeDatas;

@end

NS_ASSUME_NONNULL_END
