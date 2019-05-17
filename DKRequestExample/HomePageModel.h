//
//  HomePageModel.h
//  Jide
//
//  Created by jingzhao on 2018/11/7.
//  Copyright © 2018 jide. All rights reserved.
//

#import <YYModel/YYModel.h>
#import <Foundation/Foundation.h>
@interface HomePageDetailModel :NSObject
@property (nonatomic,strong)NSString *img;
@property (nonatomic,strong)NSString *id_;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *infolink;
@property (nonatomic,strong)NSString *vname;
@property (nonatomic,strong)NSString *alias;
@property (nonatomic,strong)NSString *isfalse;
@property (nonatomic,strong)NSString *teacher;
@end

@interface HomePageModel : NSObject
@property (nonatomic,strong)NSArray <HomePageDetailModel *> *backimg;
@property (nonatomic,strong)NSArray <HomePageDetailModel *>*news;
@property (nonatomic,strong)NSArray <HomePageDetailModel *>*xshy;
@property (nonatomic,strong)NSArray <HomePageDetailModel *>*abouts;
@property (nonatomic,strong)NSArray <HomePageDetailModel *>*slist;
@property (nonatomic,strong)NSArray <HomePageDetailModel *>*klist;
@end



