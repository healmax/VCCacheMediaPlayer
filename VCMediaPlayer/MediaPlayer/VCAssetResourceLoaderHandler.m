//
//  VCAssetResourceLoaderHandler.m
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/15.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import "VCAssetResourceLoaderHandler.h"
#import "VCMediaDownloadManager.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface VCAssetResourceLoaderHandler()<NSURLSessionDataDelegate, VCMediaDownloadManagerDelegate>

@property (nonatomic, strong) id<VCMediaPlayInfoProtocol> mediaInfo;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray<AVAssetResourceLoadingRequest *> *pendingRequests;


@property (nonatomic, strong, readwrite) VCMediaDownloadManager *manager;

@end

@implementation VCAssetResourceLoaderHandler

+ (VCAssetResourceLoaderHandler *)resourceLoaderHandlerWithMediaInfo:(id<VCMediaPlayInfoProtocol>)mediaInfo {
    VCAssetResourceLoaderHandler *handler = [[VCAssetResourceLoaderHandler alloc] init];
    handler.mediaInfo = mediaInfo;
    return handler;
}

- (instancetype)init {
    if (self = [super init]) {
        _pendingRequests = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    if (!self.manager) {
        NSURL *url = loadingRequest.request.URL;
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:YES];
        components.scheme = @"http";
        
        self.manager = [[VCMediaDownloadManager alloc] initWithMediaInfo:self.mediaInfo];
        self.manager.delegate = self;
        [self.manager startDownload];
    }
    
    [self.pendingRequests addObject:loadingRequest];
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest  {
    [self.pendingRequests removeObject:loadingRequest];
}

#pragma mark - VCMediaDownloadManagerDelegate

- (void)mediaDownloadManager:(VCMediaDownloadManager *)manager dataUpdate:(NSMutableData *)data {
    [self processing];
}

#pragma mark - private

- (void)processing {
    NSMutableArray *completeRequest = [NSMutableArray new];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests) {
        [self fillContentInfomationRequest:loadingRequest.contentInformationRequest];
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest];
        
        if (didRespondCompletely) {
            [loadingRequest finishLoading];
            [completeRequest addObject:loadingRequest];
        }
    }
    
    [self.pendingRequests removeObjectsInArray:[completeRequest copy]];
}

- (void)fillContentInfomationRequest:(AVAssetResourceLoadingContentInformationRequest *)request {
    
    NSString *mimeType = [self.manager fetchMIMEType];
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    
    request.byteRangeAccessSupported = YES;
    request.contentType = CFBridgingRelease(contentType);
    request.contentLength = [self.manager expectedContentLength];
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest {
    
    long long startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset - self.manager.dataOffset;
    }
    
    if (self.manager.downloadedDataLength < startOffset) {
        return NO;
    }
    
    NSUInteger canReadBytes = self.manager.remainingDataLength - startOffset;
    NSUInteger remainingBytes = (dataRequest.requestedOffset + dataRequest.requestedLength) - dataRequest.currentOffset;
    NSUInteger numberOfBytesToRespondWith = MIN(remainingBytes, canReadBytes);
    
//    NSLog(@"==============================================\n");
//    NSLog(@"requestOffset : %@", @(dataRequest.requestedOffset));
//    NSLog(@"requestedLength : %@", @(dataRequest.requestedLength));
//    NSLog(@"currentOffset : %@", @(dataRequest.currentOffset));
    
    [dataRequest respondWithData:[self.manager.mediaData subdataWithRange:NSMakeRange((NSUInteger)startOffset, numberOfBytesToRespondWith)]];
    
    long long endOffset = dataRequest.requestedOffset + dataRequest.requestedLength;
    BOOL didRespondFully = self.manager.downloadedDataLength >= endOffset;
    
    return didRespondFully;
}

@end
