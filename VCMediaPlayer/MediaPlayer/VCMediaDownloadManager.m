//
//  VCMediaDownloadManager.m
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/15.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import "VCMediaDownloadManager.h"
#import "MediaPlayInfo.h"
#import "DownloadFileHandle.h"

#import <UIKit/UIKit.h>

static NSString * const kMediaFolder = @"Media";
static CGFloat const kMaximumBufferMBSize = 2.f;

@interface VCMediaDownloadManager()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) id<VCMediaPlayInfoProtocol> mediaInfo;

@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong, readwrite) NSMutableData *mediaData;
@property (nonatomic, assign, readwrite) NSUInteger downloadedDataLength;
@property (nonatomic, assign, readwrite) NSUInteger dataOffset;

@end

@implementation VCMediaDownloadManager

- (instancetype)initWithMediaInfo:(id<VCMediaPlayInfoProtocol>)mediaInfo {
    if (self = [super init]) {
        _mediaInfo = mediaInfo;
        _dataOffset = 0;
        _downloadedDataLength = 0;
        _dataOffset = 0;
    }
    
    return self;
}

#pragma mark - NSURLSessionDataDelegate

/**
 接收到服务器的响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    //【注意：此处需要允许处理服务器的响应，才会继续加载服务器的数据。 若在接收响应时需要对返回的参数进行处理(如获取响应头信息等),那么这些处理应该放在这个允许操作的前面。】
    self.mediaData = [NSMutableData new];
    self.response = (NSHTTPURLResponse *)response;
    completionHandler(NSURLSessionResponseAllow);
}

/**
 接收到服务器的数据（此方法在接收数据过程会多次调用）
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    self.downloadedDataLength += data.length;
    [self.mediaData appendData:data];
    if ([self.delegate respondsToSelector:@selector(mediaDownloadManager:dataUpdate:)]) {
        [self.delegate mediaDownloadManager:self dataUpdate:self.mediaData];
    }
    
    [self saveDataIfNeeded];
}

/**
 任务完成时调用（如果成功，error == nil）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self deleteTempMediaFile];
        return;
    }
    
    [self saveDataAndMoveToCacheMediaDownloadPath];
    [self deleteTempMediaFile];
}

#pragma mark - public

- (void)startDownload {
    [self createTempMediaFile];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.mediaInfo.mediaURL];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}

- (void)cancelDownload {
    [self deleteTempMediaFile];
    [self.session invalidateAndCancel];
    [self.task cancel];
    self.session = nil;
    self.task = nil;
}

- (NSString *)fetchMIMEType {
    return [self.response MIMEType];
}

#pragma mark - private

- (void)createTempMediaFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:self.mediaInfo.tempMediaDownloadPath]) {
        [manager removeItemAtPath:self.mediaInfo.tempMediaDownloadPath error:nil];
    }
    
    if ([manager createFileAtPath:self.mediaInfo.tempMediaDownloadPath contents:nil attributes:nil]) {
        NSLog(@"Complete");
    }
}

- (void)deleteTempMediaFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:self.mediaInfo.tempMediaDownloadPath]) {
        [manager removeItemAtPath:self.mediaInfo.tempMediaDownloadPath error:nil];
    }
}

- (void)saveDataIfNeeded {
    CGFloat currentMBSize = self.mediaData.length/1024.f/1024.f;
    if (currentMBSize > kMaximumBufferMBSize) {
        [self saveData];
    }
}

- (void)saveData {
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.mediaInfo.tempMediaDownloadPath];
    [handle seekToEndOfFile];
    [handle writeData:self.mediaData];
    self.dataOffset = self.downloadedDataLength;
    [self.mediaData setLength:0];
}

- (void)saveDataAndMoveToCacheMediaDownloadPath {
    [self saveData];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    NSString *folderPath = [self.mediaInfo.cacheMediaDownloadPath stringByDeletingLastPathComponent];
    [filemanager fileExistsAtPath:folderPath isDirectory:&isDir];
    if (!isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([filemanager moveItemAtPath:self.mediaInfo.tempMediaDownloadPath toPath:self.mediaInfo.cacheMediaDownloadPath error: NULL]) {
        NSLog(@"saveDataAndMoveToCacheMediaDownloadPath Success");
    } else {
        NSLog(@"saveDataAndMoveToCacheMediaDownloadPath Fail");
    }
}

#pragma mark - accessor

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:NSOperationQueue.mainQueue];
    }
    
    return _session;
}

- (long long)expectedContentLength {
    return self.response.expectedContentLength;
}

- (NSUInteger)remainingDataLength {
    return self.mediaData.length;
}

@end
