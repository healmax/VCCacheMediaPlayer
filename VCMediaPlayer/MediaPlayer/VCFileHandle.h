//
//  VCFileHandle.h
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/18.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCFileHandle : NSObject

+ (NSURL *)URLCacheFileExistsWithPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
