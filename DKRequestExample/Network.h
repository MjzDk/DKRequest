//
//  Network.h
//  DKRequestExample
//
//  Created by mini on 2019/4/12.
//  Copyright © 2019 mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomePageModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface Network : NSObject
#pragma mark - 首页
/**
 获取轮播图
 
 @param successBlock 成功
 @param failBlock 失败
 */
+(void)apiRequestHomePageInfosuccessBlock:(void(^)(HomePageModel*model))successBlock
                                failBlock:(void(^)(NSError *error))failBlock;

/**
 获取学习中心数据
 
 @param cate newsname
 @param successBlock 成功
 @param failBlock 失败
 */
+(void)apiGetStudyCenterWithCate:(NSString*)cate
                    successBlock:(void(^)(NSArray<HomePageDetailModel *>*scrollImageArray))successBlock
                       failBlock:(void(^)(NSError*error))failBlock;
@end

NS_ASSUME_NONNULL_END
