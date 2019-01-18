//
//  VCMediaDownloadManager.h
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/15.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MediaPlayInfo;
@class VCMediaDownloadManager;

@protocol VCMediaPlayInfoProtocol;

@protocol VCMediaDownloadManagerDelegate <NSObject>

- (void)mediaDownloadManager:(VCMediaDownloadManager *)manager dataUpdate:(NSMutableData *)data;

@end

@interface VCMediaDownloadManager : NSObject

@property (nonatomic, assign, readonly) long long expectedContentLength;

@property (nonatomic, assign, readonly) NSUInteger dataOffset;
@property (nonatomic, assign, readonly) NSUInteger downloadedDataLength;
@property (nonatomic, assign, readonly) NSUInteger remainingDataLength;

@property (nonatomic, strong, readonly) NSMutableData *mediaData;

@property (nonatomic, weak) id<VCMediaDownloadManagerDelegate> delegate;

- (instancetype)initWithMediaInfo:(id<VCMediaPlayInfoProtocol>)mediaInfo;

- (void)startDownload;
- (void)cancelDownload;
- (NSString *)fetchMIMEType;

@end

NS_ASSUME_NONNULL_END
