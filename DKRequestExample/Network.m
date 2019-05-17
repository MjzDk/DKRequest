//
//  Network.m
//  DKRequestExample
//
//  Created by mini on 2019/4/12.
//  Copyright © 2019 mini. All rights reserved.
//

#import "Network.h"
#import "Request.h"
#pragma mark - 首页
#define AipAddress @"http://api.sxjdpk1.com"
//首页轮播
#define Api_scroll_image [NSString stringWithFormat:@"%@/",AipAddress]

//学习中心轮播
#define Api_Study_Center [NSString stringWithFormat:@"%@/classindex",AipAddress]
@implementation Network

#pragma mark - 首页
/*
 TODO:获取首页
 */
+(void)apiRequestHomePageInfosuccessBlock:(void(^)(HomePageModel*model))successBlock
                                failBlock:(void(^)(NSError *error))failBlock{
    [[Request shareRequest] postWithUrl:Api_scroll_image parameters:nil success:^(id responseObject) {
        NSString *code = [NSString stringWithFormat:@"%@",responseObject[@"code"]];
        if ([code isEqualToString:@"200"]) {
            HomePageModel *model = [HomePageModel yy_modelWithJSON:responseObject[@"data"]];
            successBlock(model);
        }else{
//            makeToast(responseObject[@"msg"]);
            NSError *error;
            failBlock(error);
        }
    } fail:^(NSError *error, NSURLSessionDataTask *task) {
        failBlock(error);
    }];
}
/*
 TODO:获取学习中心类目
 */
+(void)apiGetStudyCenterWithCate:(NSString *)cate successBlock:(void (^)(NSArray<HomePageDetailModel *>*scrollImageArray))successBlock failBlock:(void (^)(NSError *))failBlock{
    NSDictionary *parameters = @{@"cate":cate};
    [[Request shareRequest] postWithUrl:Api_Study_Center parameters:parameters success:^(id responseObject) {
        NSString *code = [NSString stringWithFormat:@"%@",responseObject[@"code"]];
        if ([code isEqualToString:@"200"]) {
            HomePageModel *model = [HomePageModel yy_modelWithJSON:responseObject[@"data"]];
            successBlock(model.backimg);
        }else{
//            makeToast(responseObject[@"msg"]);
            NSError *error;
            failBlock(error);
        }
    } fail:^(NSError *error, NSURLSessionDataTask *task) {
        failBlock(error);
    }];
}
@end
