//
//  HomePageVC.m
//  Jide
//
//  Created by jingzhao on 2018/11/7.
//  Copyright © 2018 jide. All rights reserved.
//

#import "HomePageVC.h"
#import "TitleView.h"
#import <SDCycleScrollView.h>
#import "MenuButton.h"
#import "MenuView.h"
#import "ScrollInfoView.h"
#import "HomePageCell.h"
#import "StudyCenterVC.h"
#import "NewsVC.h"
#import "BeautifulDoctorVC.h"
#import "StudyBestVC.h"
#import "MazhenyouVC.h"
#import "ClinicShowVC.h"
#import "ShopVC.h"
#import "XueShuHuiYiCell.h"
#import "ClassDetaileVC.h"
#import "HotClassCell.h"
#import "OnLiveVC.h"
#import "ChatListVC.h"
#import <RongIMKit/RongIMKit.h>
#define MenuViewHeight ((SCREEN_WIDTH-5*15)/5+15)*2+5
@interface HomePageVC ()<UITableViewDelegate,UITableViewDataSource,SDCycleScrollViewDelegate,UIScrollViewDelegate,MenuViewDelegate,ScrollInfoViewDelegate>
@property (nonatomic,strong)TitleView *titleView;//导航
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)SDCycleScrollView *topView;//轮播图
@property (nonatomic,strong)MenuView *menuView;
@property (nonatomic,strong)ScrollInfoView *scrollInfoView; //行业资讯
@property (nonatomic,strong)NSMutableArray *sectionTitleArray; //标题
@property (nonatomic,strong)HomePageModel *model;
@end

@implementation HomePageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
    [self setRequest];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    WeakSelf(self)
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakself setRequest];
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
#pragma mark - UI
-(void)setUI{
    [self.scrollView addSubview:self.topView];
    [self.scrollView addSubview:self.menuView];
    [self.scrollView addSubview:self.scrollInfoView];
    [self.scrollView addSubview:self.tableView];
    [self.view addSubview:self.scrollView];
    [self.view insertSubview:self.titleView aboveSubview:self.scrollView];
    
}
#pragma mark - Network
-(void)setRequest{
    WeakSelf(self)
    [JideNetwork apiRequestHomePageInfosuccessBlock:^(HomePageModel *model) {
        weakself.model = model;
        [weakself netWrokSuccess];
        [weakself.scrollView.mj_header endRefreshing];
    } failBlock:^(NSError *error) {
        [weakself.scrollView.mj_header endRefreshing];
    }];
}
-(void)netWrokSuccess{
    //轮播
    NSMutableArray *tmpScrollImage = [NSMutableArray array];
    for (HomePageDetailModel*model in self.model.backimg) {
        [tmpScrollImage addObject:model.img];
    }
    self.topView.imageURLStringsGroup = tmpScrollImage;
    //资讯
    NSMutableArray *scrollTitleArray = [NSMutableArray array];
    for (HomePageDetailModel*model in self.model.news) {
        [scrollTitleArray addObject:model.title];
    }
    self.scrollInfoView.textArray = scrollTitleArray;
    //学术会议
    [self.tableView reloadData];
}
#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    NSLog(@"点击了第%ld张图片",(long)index);
}
#pragma mark - MenuViewDelegate
-(void)selectedMenuType:(MenuType)menuType{
    
    switch (menuType) {
        case MenuTypeStudyCenter:{
            NSLog(@"学习中心");
            [self pushStudyVC];
        }
            break;
        case MenuTypeLiveRoom:{
            NSLog(@"直播间");
            OnLiveVC *vc = [[OnLiveVC alloc] init];
            vc.titleString = @"房间列表";
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            
            break;
        case MenuTypeConsultationCenter:{
            NSLog(@"会诊中心");
            WeakSelf(self);
            showHUDAndActivity(@"加载中", self.view);
            [JideNetwork getIMInfoWithUserid:[JideGlobal shareGlobal].userModel.id_ successBlock:^(ChatInfoModel *model) {
                
                [[RCIM sharedRCIM] initWithAppKey:RongYunKey];
                [[RCIM sharedRCIM] connectWithToken:model.token     success:^(NSString *userId) {
                    NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
                } error:^(RCConnectErrorCode status) {
                    NSLog(@"登陆的错误码为:%ld", (long)status);
                } tokenIncorrect:^{
                    //token过期或者不正确。
                    //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
                    //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
                    NSLog(@"token错误");
                }];
                ChatListVC *vc = [[ChatListVC alloc] init];
                vc.model = model;
                vc.hidesBottomBarWhenPushed = YES;
                [weakself.navigationController pushViewController:vc animated:YES];
                hiddenMBHUD(weakself.view);
            } failBlock:^(NSError *error) {
                hiddenMBHUD(weakself.view);
            }];
        }
            break;
        case MenuTypeMaZhenYou:{
            MazhenyouVC *vc = [[MazhenyouVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.subVcTitleArray = @[@"个人简介",@"医学成就",@"TA的课程",@"TA的讲座"];
            [self.navigationController pushViewController:vc animated:YES];
            NSLog(@"马振友专区");
        }
            break;
        case MenuTypeNews:{
            [self pushMoreNewsVC];
        }
            NSLog(@"行业资讯");
            break;
        case MenuTypeDoctor:{
            BeautifulDoctorVC *vc = [[BeautifulDoctorVC alloc] init];
            vc.type = pushTypeDoctor;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            NSLog(@"最美医生");
        }
            break;
        case MenuTypeStudyBest:{
            StudyBestVC *vc = [[StudyBestVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            NSLog(@"学霸擂台");
        }
            
            break;
        case MenuTypeClinic:{
            NSLog(@"诊所展示");
            ClinicShowVC *vc = [[ClinicShowVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MenuTypeShop:{
            ShopVC *vc = [[ShopVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            NSLog(@"商城");
        }
            break;
        case MenuTypeJide:{
            BeautifulDoctorVC *vc = [[BeautifulDoctorVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.type = pushTypeAbout;
            [self.navigationController pushViewController:vc animated:YES];
            NSLog(@"济德风采");
        }
            break;
            
        default:
            break;
    }
}
//资讯
-(void)pushMoreNewsVC{
    NewsVC *vc = [[NewsVC alloc] init];
    vc.subVcTitleArray = @[@"行业资讯",@"学术会议"];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)pushStudyVC{
    StudyCenterVC *vc = [[StudyCenterVC alloc] init];
    vc.subVcTitleArray = @[@"名师介绍",@"视频课程",@"TXT文本",@"PDF课程"];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)pushNewsDetailWithModel:(HomePageDetailModel*)model{
    BaseWebViewController *web = [[BaseWebViewController alloc] init];
    web.title = self.title;
    TeacherModel *teacherModel = [[TeacherModel alloc] init];
    if (model) {
        teacherModel = (TeacherModel*)model;
    }
    web.urlStr = [NSString stringWithFormat:@"%@/%@",Api_news,teacherModel.id_];
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}
#pragma mark - ScrollInfoViewDelegate
-(void)moreNewsClick{
    NSLog(@"更多资讯");
    [self pushMoreNewsVC];
}
-(void)didClickScrollIndex:(NSInteger)index text:(NSString *)text{
    NSLog(@"当前点击的是第%ld个  内容为%@",index,text);
    BaseWebViewController *web = [[BaseWebViewController alloc] init];
    web.title = self.title;
    TeacherModel *teacherModel = [[TeacherModel alloc] init];
    if (self.model) {
        teacherModel = (TeacherModel*)self.model.news[index];
    }
    web.urlStr = [NSString stringWithFormat:@"%@/%@",Api_news,teacherModel.id_];
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}
#pragma mark - <UITableViewDelegate,UITableViewDataSource>
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    sectionView.backgroundColor = [UIColor clearColor];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, SCREEN_WIDTH, 32)];
    bgView.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, bgView.height)];
    titleLabel.text = self.sectionTitleArray[section];
    titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    [bgView addSubview:titleLabel];
    UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-90, 0, 80, bgView.height)];
    [moreBtn setTitle:@"更多" forState:(UIControlStateNormal)];
    [moreBtn setImage:[UIImage imageNamed:@"jinru"] forState:(UIControlStateNormal)];
    [moreBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -90)];
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    moreBtn.tag = 123+section;
    [moreBtn addTarget:self action:@selector(moreInfomationClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [moreBtn setTitleColor:APP_MAIN_COLOR forState:(UIControlStateNormal)];
    [bgView addSubview:moreBtn];
    [sectionView addSubview:bgView];
    return sectionView;
}
-(void)moreInfomationClick:(UIButton*)sender{
    switch (sender.tag) {
        case 123://学术会议
            [self moreNewsClick];
            break;
        case 124://直播
            self.tabBarController.selectedIndex = 1;
            break;
        case 125://热门课程
            [self pushStudyVC];
            break;
        default:
            break;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(self)
    if (indexPath.section == 0)/*学术会议*/ {
        XueShuHuiYiCell *cell = [XueShuHuiYiCell cellWithTabelView:tableView];
        cell.dataArray = self.model.xshy ? self.model.xshy : nil;
        cell.selectedBlock = ^(HomePageDetailModel * _Nonnull model) {
            [weakself pushNewsDetailWithModel:model];
        };
        return cell;
    }else if (indexPath.section == 1){
        HomePageCell *cell = [HomePageCell cellWithTabelView:tableView];
        cell.cellType = HomePageCellTypeLive;
        cell.modelArray = self.model.slist;
        cell.selectedBlock = ^(HomePageDetailModel *model) {
            [JideNetwork apiGetOnLiveDetailWithAlias:model.alias successBlock:^(id data) {
                
            } failBlock:^(NSError *error) {
                
            }];
        };
        return cell;
    }else{
        HotClassCell *cell = [[HotClassCell alloc] init];
        cell.modelArray = self.model.klist;
        cell.selectedBlock = ^(HomePageDetailModel * _Nonnull model) {
            ClassDetaileVC *vc = [[ClassDetaileVC alloc] init];
            vc.id_ = model.id_;
            vc.hidesBottomBarWhenPushed = YES;
            [weakself.navigationController pushViewController:vc animated:YES];
        };
        return cell;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return (SCREEN_WIDTH-50)/3+20;
    }
    if (indexPath.section == 2) {
        return ((SCREEN_WIDTH-50)/3+45)*2;
    }
    return (SCREEN_WIDTH-50)/3+45;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    if (section == 0) {
    return 0.01;
//    }
//    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
//    if (section == 0) {
//        return nil;
//    }
//    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
//    [footView setBackgroundColor:[UIColor whiteColor]];
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
//    button.center = footView.center;
//    button.layer.masksToBounds = YES;
//    button.layer.cornerRadius = 15.f;
//    [button setImage:[UIImage imageNamed:@"huan"] forState:(UIControlStateNormal)];
//    [button setTitle:@"换一批" forState:(UIControlStateNormal)];
//    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
//    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
//    button.titleLabel.font = [UIFont systemFontOfSize:14.f];
//    [button setTitleColor:APP_MAIN_COLOR forState:(UIControlStateNormal)];
//    button.backgroundColor = [UIColor colorWithRed:0/255.5 green:170/255.0 blue:180/255.0 alpha:0.3];
//    [footView addSubview:button];
//    return footView;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = self.scrollView.contentOffset.y;
    
    if (offsetY<0) {
        self.titleView.alpha = 0;
    }if (offsetY>0&&offsetY<=getRectNavAndStatusHight) {
        self.titleView.alpha = offsetY/64;
    }else if(offsetY>getRectNavAndStatusHight){
        self.titleView.alpha = 1;
    }
}
#pragma mark - 懒加载
-(TitleView *)titleView{
    if (!_titleView) {
        _titleView = [[TitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, getRectNavAndStatusHight) title:@"首页" leftImageName:nil leftTitle:nil rightImageName:nil rightTitle:nil leftClick:nil rightClick:nil];
        _titleView.alpha = 0;
    }
    return _titleView;
}
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-TabBarHeight)];
        _scrollView.delegate = self;
        _scrollView.scrollEnabled = YES;
    }
    return _scrollView;
}
-(SDCycleScrollView *)topView{
    if (!_topView) {
        _topView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, StatusHeight, SCREEN_WIDTH, TopScrollHeight) delegate:self placeholderImage:[UIImage imageNamed:@"scroll_placehoulder_image"]];
        _topView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    }
    return _topView;
}
-(MenuView *)menuView{
    if (!_menuView) {
        _menuView = [[MenuView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topView.frame), SCREEN_WIDTH, MenuViewHeight)];
        _menuView.titleArray = @[@"学习中心",@"直播间",@"会诊中心",@"马振友专区",@"商城",@"行业资讯",@"最美医生",@"学霸擂台",@"诊所展示",@"济德风采"];
        _menuView.imageArray = @[@"nav_01",@"nav_02",@"nav_03",@"nav_04",@"nav_05",@"nav_06",@"nav_07",@"nav_08",@"nav_09",@"nav_10"];
        _menuView.delegate = self;
    }
    return _menuView;
}
-(ScrollInfoView *)scrollInfoView{
    if (!_scrollInfoView) {
        _scrollInfoView = [[ScrollInfoView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.menuView.frame)+8, SCREEN_WIDTH, 40)];
        _scrollInfoView.delegate = self;
    }
    return _scrollInfoView;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollInfoView.frame), SCREEN_WIDTH, ((SCREEN_WIDTH-50)/3+20)+((SCREEN_WIDTH-50)/3+45)+(((SCREEN_WIDTH-50)/3+45)*2)+3*40) style:(UITableViewStyleGrouped)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(_tableView.frame));
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}
-(NSMutableArray *)sectionTitleArray{
    if (!_sectionTitleArray) {
        _sectionTitleArray = [NSMutableArray arrayWithArray:@[@"学术会议",@"直播",@"热门课程"]];
    }
    return _sectionTitleArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
