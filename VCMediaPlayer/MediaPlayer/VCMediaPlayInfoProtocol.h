//
//  VCMediaPlayInfoProtocol.h
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/16.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VCMediaPlayInfoProtocol <NSObject>

// media download URL
@property (nonatomic, strong) NSURL *mediaURL;
// media AlbumURL
@property (nonatomic, strong) NSURL *mediaAlbumURL;
// media Name
@property (nonatomic, copy) NSString *mediaName;
// the temp download path for downloading.
@property (nonatomic, copy) NSString *tempMediaDownloadPath;
// after download finished, file will be moved from tempMediaDownloadPath to cacheMediaDownloadPath;
@property (nonatomic, copy) NSString *cacheMediaDownloadPath;


@end

NS_ASSUME_NONNULL_END
