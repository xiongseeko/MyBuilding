//
//  MyMarketViewController.m
//  ZhuZhan
//
//  Created by 汪洋 on 15/6/10.
//
//

#import "MyMarketViewController.h"
#import "MarketPopView.h"
#import "MarketListSearchViewController.h"
#import "RequirementDetailViewController.h"
#import "PublishRequirementViewController.h"
#import "RKStageChooseView.h"
#import "AppDelegate.h"
#import "HomePageViewController.h"
#import "MarketPublicListViewController.h"
#import "MJRefresh.h"
#import "MarketModel.h"
#import "MarketApi.h"
#import "MarkListTableViewCell.h"
#import "LoginViewController.h"
#import "LoginSqlite.h"
#import "AddressBookApi.h"
#import "ChatViewController.h"

@interface MyMarketViewController ()<RKStageChooseViewDelegate,UITableViewDelegate,UITableViewDataSource,MarketPopViewDelegate,MarkListTableViewCellDelegate,LoginViewDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)NSString *requireType;
@property(nonatomic)int startIndex;
@property(nonatomic,strong)MarketPopView *popView;
@property(nonatomic,strong)RKStageChooseView *stageChooseView;
@property(nonatomic,strong)MarketPublicListViewController *publicListView;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *modelsArr;
@property(nonatomic)NSInteger stageNumber;
@property(nonatomic,strong)NSString *isOpen;//00公开 01客服
@property(nonatomic,strong)MarketModel *marketModel;
@end

@implementation MyMarketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNav];
    self.startIndex = 0;
    self.requireType = @"";
    [self.view addSubview:self.tableView];
    [self initStageChooseViewWithStages:@[@"公开需求",@"客服需求"] numbers:nil underLineIsWhole:YES normalColor:AllLightGrayColor highlightColor:BlueColor];
    //集成刷新控件
    [self setupRefresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requirementListReload) name:@"RequirementListReload" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNav{
    //LeftButton设置属性
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 25, 22)];
    [leftButton setBackgroundImage:[GetImagePath getImagePath:@"013"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 40, 20);
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchBtnAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    UIButton *screeningBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    screeningBtn.frame = CGRectMake(0, 0, 40, 20);
    screeningBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [screeningBtn setTitle:@"筛选" forState:UIControlStateNormal];
    [screeningBtn addTarget:self action:@selector(screeningBtnAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *screeningItem = [[UIBarButtonItem alloc] initWithCustomView:screeningBtn];
    
    UIButton *releaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    releaseBtn.frame = CGRectMake(0, 0, 40, 20);
    releaseBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [releaseBtn setTitle:@"发布" forState:UIControlStateNormal];
    [releaseBtn addTarget:self action:@selector(releaseBtnAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *releaseItem = [[UIBarButtonItem alloc] initWithCustomView:releaseBtn];
    self.navigationItem.rightBarButtonItems = @[releaseItem,screeningItem,searchItem];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //恢复tabBar
    AppDelegate* app=[AppDelegate instance];
    HomePageViewController* homeVC=(HomePageViewController*)app.window.rootViewController;
    [homeVC homePageTabBarRestore];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    //隐藏tabBar
    AppDelegate* app=[AppDelegate instance];
    HomePageViewController* homeVC=(HomePageViewController*)app.window.rootViewController;
    [homeVC homePageTabBarHide];
}

-(void)leftBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)searchBtnAction{
    MarketListSearchViewController *searchView = [[MarketListSearchViewController alloc] init];
    if(self.stageNumber == 0){
        searchView.isPublic = YES;
    }else{
        searchView.isPublic = NO;
    }
    [self.navigationController pushViewController:searchView animated:YES];
}

-(void)screeningBtnAction{
    [self.view.window addSubview:self.popView];
}

-(void)releaseBtnAction{
    PublishRequirementViewController* vc = [[PublishRequirementViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)closePopView{
    [self.popView removeFromSuperview];
    self.popView = nil;
}

-(void)selectIndex:(NSInteger)index{
    [self.popView removeFromSuperview];
    self.popView = nil;
    switch (index) {
        case 0:
            //全部
            self.requireType = @"";
            break;
        case 1:
            //找项目
            self.requireType = @"01";
            break;
        case 2:
            //找材料
            self.requireType = @"02";
            break;
        case 3:
            //找合作
            self.requireType = @"04";
            break;
        case 4:
            //找关系
            self.requireType = @"03";
            break;
        case 5:
            //其他
            self.requireType = @"05";
            break;
        default:
            break;
    }
    [self loadList];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

-(void)initStageChooseViewWithStages:(NSArray*)stages numbers:(NSArray*)numbers underLineIsWhole:(BOOL)underLineIsWhole normalColor:(UIColor *)normalColor highlightColor:(UIColor *)highlightColor{
    self.stageChooseView=[RKStageChooseView stageChooseViewWithStages:
                          stages numbers:numbers delegate:self underLineIsWhole:underLineIsWhole normalColor:normalColor highlightColor:highlightColor];
    CGRect frame=self.stageChooseView.frame;
    frame.origin=CGPointMake(0, 64);
    self.stageChooseView.frame=frame;
    [self.view addSubview:self.stageChooseView];
}

- (void)stageBtnClickedWithNumber:(NSInteger)stageNumber{
    self.stageNumber = stageNumber;
    switch (stageNumber) {
        case 0:
            self.isOpen = @"00";
            self.requireType = @"";
            [self loadList];
            break;
        case 1:
            self.isOpen = @"01";
            self.requireType = @"";
            [self loadList];
            break;
        default:
            break;
    }
}

-(NSMutableArray *)modelsArr{
    if(!_modelsArr){
        _modelsArr = [NSMutableArray array];
    }
    return _modelsArr;
}

-(MarketPopView *)popView{
    if(!_popView){
        _popView = [[MarketPopView alloc] initWithFrame:self.view.bounds];
        self.popView.delegate = self;
    }
    return _popView;
}

-(UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 46, 320, kScreenHeight-46)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = RGBCOLOR(239, 237, 237);
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelsArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MarkListTableViewCell carculateCellHeightWithModel:self.modelsArr[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = [NSString stringWithFormat:@"Cell"];
    MarkListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[MarkListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    MarketModel* model = self.modelsArr[indexPath.row];
    model.a_needBtn = YES;
    cell.marketModel = model;
    cell.contentView.backgroundColor = RGBCOLOR(239, 237, 237);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.indexPath = indexPath;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MarketModel *model = self.modelsArr[indexPath.row];
    RequirementDetailViewController* vc = [[RequirementDetailViewController alloc] initWithTargetId:model.a_id];
    vc.needAssistBtn = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)addFriend:(NSIndexPath *)indexPath{
    if([[LoginSqlite getdata:@"userId"] isEqualToString:@""]){
        [self gotoLoginView];
    }else{
        MarketModel *model = self.modelsArr[indexPath.row];
        if(model.a_isFriend){
            [self gotoChatView:model];
        }else{
            [self gotoAddFriend:model];
        }
    }
}

-(void)gotoLoginView{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.needDelayCancel=YES;
    loginVC.delegate = self;
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self.view.window.rootViewController presentViewController:nv animated:YES completion:nil];
}

-(void)gotoAddFriend:(MarketModel *)model{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:model.a_loginId forKey:@"userId"];
    [AddressBookApi PostSendFriendRequestWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"发送成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }else{
            if([ErrorCode errorCode:error] == 403){
                [LoginAgain AddLoginView:NO];
            }else{
                [ErrorCode alert];
            }
        }
    } dic:dic noNetWork:^{
        [ErrorCode alert];
    }];
}

-(void)gotoChatView:(MarketModel *)model{
    ChatViewController* vc=[[ChatViewController alloc]init];
    vc.contactId=model.a_loginId;
    vc.titleStr = model.a_loginName;
    vc.type=@"01";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)loginCompleteWithDelayBlock:(void (^)())block{
    [self loadList];
    if(block){
        block();
    }
}

-(void)delRequire:(NSIndexPath *)indexPath{
    if([[LoginSqlite getdata:@"userId"] isEqualToString:@""]){
        [self gotoLoginView];
    }else{
        MarketModel *model = self.modelsArr[indexPath.row];
        self.marketModel = model;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否删除需求" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self gotoDelete:self.marketModel];
    }
}

-(void)gotoDelete:(MarketModel *)model{
    [MarketApi DelRequireWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            [self loadList];
        }else{
            if([ErrorCode errorCode:error] == 403){
                [LoginAgain AddLoginView:NO];
            }else{
                [ErrorCode alert];
            }
        }
    } dic:[@{@"reqId":model.a_id} mutableCopy] noNetWork:^{
        [ErrorCode alert];
    }];
}

-(void)loadList{
    self.startIndex = 0;
    [MarketApi GetAllMyListWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            [self.modelsArr removeAllObjects];
            self.modelsArr = posts;
            if(self.modelsArr.count == 0){
                [MyTableView reloadDataWithTableView:self.tableView];
                [MyTableView hasData:self.tableView];
            }else{
                [MyTableView removeFootView:self.tableView];
                [self.tableView reloadData];
            }
        }else{
            if([ErrorCode errorCode:error] == 403){
                [LoginAgain AddLoginView:NO];
            }else{
                [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, kScreenHeight) superView:self.view reloadBlock:^{
                    [self loadList];
                }];
            }
        }
        [self.tableView headerEndRefreshing];
    } startIndex:0 requireType:self.requireType keywords:@"" isOpen:self.isOpen noNetWork:^{
        [self.tableView headerEndRefreshing];
        [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, kScreenHeight) superView:self.view reloadBlock:^{
            [self loadList];
        }];
    }];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing{
    [self loadList];
}

- (void)footerRereshing{
    [MarketApi GetAllMyListWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            self.startIndex ++;
            [self.modelsArr addObjectsFromArray:posts];
            if(self.modelsArr.count == 0){
                [MyTableView reloadDataWithTableView:self.tableView];
                [MyTableView hasData:self.tableView];
            }else{
                [MyTableView removeFootView:self.tableView];
                [self.tableView reloadData];
            }
        }else{
            if([ErrorCode errorCode:error] == 403){
                [LoginAgain AddLoginView:NO];
            }else{
                [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, kScreenHeight) superView:self.view reloadBlock:^{
                    [self loadList];
                }];
            }
        }
        [self.tableView footerEndRefreshing];
    } startIndex:self.startIndex+1 requireType:self.requireType keywords:@"" isOpen:self.isOpen noNetWork:^{
        [self.tableView footerEndRefreshing];
        [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, kScreenHeight) superView:self.view reloadBlock:^{
            [self loadList];
        }];
    }];
}

-(void)requirementListReload{
    [self loadList];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RequirementListReload" object:nil];
}
@end
