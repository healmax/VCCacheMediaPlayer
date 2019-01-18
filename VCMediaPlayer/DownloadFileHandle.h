//
//  VCDownloadFileHandler.h
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/17.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadFileHandle : NSObject

NSString * VCCachesMediaDirectoryPath(void);    

NSString * VCCacheMediaFilePath(NSString *fileName);

NSString * VCTempMediaDownloadPathWithName(NSString *fileName);

@end

NS_ASSUME_NONNULL_END
