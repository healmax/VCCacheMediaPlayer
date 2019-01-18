//
//  VCAssetResourceLoaderHandler.h
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/15.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VCMediaDownloadManager;
@protocol VCMediaPlayInfoProtocol;

@interface VCAssetResourceLoaderHandler : NSObject<AVAssetResourceLoaderDelegate>

+ (VCAssetResourceLoaderHandler *)resourceLoaderHandlerWithMediaInfo:(id<VCMediaPlayInfoProtocol>)mediaInfo;

@property (nonatomic, strong, readonly) VCMediaDownloadManager *manager;

@end

NS_ASSUME_NONNULL_END
