//
//  HomePageModel.m
//  Jide
//
//  Created by jingzhao on 2018/11/7.
//  Copyright © 2018 jide. All rights reserved.
//

#import "HomePageModel.h"
@implementation HomePageDetailModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"id_" : @"id"};
}
@end

@implementation HomePageModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"backimg" : @"backimg",
             @"news" : @"news",
             @"xshy":@"xshy"
             };
}
+(NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"backimg":[HomePageDetailModel class],
             @"news":[HomePageDetailModel class],
             @"xshy":[HomePageDetailModel class],
             @"abouts":[HomePageDetailModel class],
             @"klist":[HomePageDetailModel class],
             @"slist":[HomePageDetailModel class]
             };
}
@end


