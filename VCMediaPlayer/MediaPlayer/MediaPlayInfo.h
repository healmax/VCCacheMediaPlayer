//
//  VCMediaPlayInfo.h
//  VCMediaPlayer
//
//  Created by healmax healmax on 2019/1/12.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCMediaPlayInfoProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaPlayInfo : NSObject<VCMediaPlayInfoProtocol>

- (instancetype)initWithURLString:(NSString *)URLString name:(NSString *)name imageName:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
