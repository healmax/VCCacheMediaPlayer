//
//  VCDownloadFileHandler.m
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/17.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import "DownloadFileHandle.h"

static NSString * const kMediaFolder = @"Media";

@implementation DownloadFileHandle

NSString * VCCachesMediaDirectoryPath() {
    NSString *cacheFolder = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    return [cacheFolder stringByAppendingPathComponent:kMediaFolder];
}

NSString * VCCacheMediaFilePath(NSString *fileName) {
    return [VCCachesMediaDirectoryPath() stringByAppendingPathComponent:fileName];
}

NSString * VCTempMediaDownloadPathWithName(NSString *fileName) {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}


@end
