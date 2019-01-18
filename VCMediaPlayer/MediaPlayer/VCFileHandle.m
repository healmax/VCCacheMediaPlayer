//
//  VCFileHandle.m
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/18.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import "VCFileHandle.h"

@implementation VCFileHandle

+ (NSURL *)URLCacheFileExistsWithPath:(NSString *)path {

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [NSURL fileURLWithPath:path];
    }
    return nil;
}

@end
