//
//  ViewController.m
//  DKRequestExample
//
//  Created by mini on 2019/1/7.
//  Copyright © 2019 mini. All rights reserved.
//

#import "ViewController.h"
#import "Network.h"
#import <coobjc.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    co_launch(^{
        HomePageModel*model =  await([self fetchNewMould]);
        NSLog(@"newscount %ld",model.news.count);
        NSError*error = co_getError();
        NSLog(@"error --- %@",error);
    });
}
-(COPromise *)fetchNewMould{
    COPromise *promise = [COPromise promise];
    [Network apiRequestHomePageInfosuccessBlock:^(HomePageModel * _Nonnull model) {
        [promise fulfill:model];
    } failBlock:^(NSError * _Nonnull error) {
        [promise reject:error];
    }];
    return promise;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
