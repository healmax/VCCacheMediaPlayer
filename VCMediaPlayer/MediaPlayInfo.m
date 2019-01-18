//
//  VCMediaPlayInfo.m
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/12.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import "MediaPlayInfo.h"
#import "DownloadFileHandle.h"

@interface MediaPlayInfo()

@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *name;

@end

@implementation MediaPlayInfo

@synthesize mediaURL;
@synthesize mediaAlbumURL;
@synthesize mediaName;
@synthesize cacheMediaDownloadPath;
@synthesize tempMediaDownloadPath;

- (instancetype)initWithURLString:(NSString *)URLString name:(NSString *)name imageName:(NSString *)imageName {
    if (self = [super init]) {
        _URLString = URLString;
        _name = name;
        _imageName = imageName;
    }
    
    return self;
}

#pragma mark - accessor

- (NSURL *)mediaURL {
    return [NSURL URLWithString:self.URLString];
}

- (NSURL *)mediaAlbumURL {
    return [[NSBundle mainBundle] URLForResource:self.imageName withExtension:@".jpg"];
}

- (NSString *)mediaName {
    NSString *extension = [self.mediaURL pathExtension];
    return [NSString stringWithFormat:@"%@.%@", self.name, extension];
}

- (NSString *)cacheMediaDownloadPath {
    return VCCacheMediaFilePath(self.mediaName);
}

- (NSString *)tempMediaDownloadPath {
    return VCTempMediaDownloadPathWithName(self.mediaName);
}

@end
