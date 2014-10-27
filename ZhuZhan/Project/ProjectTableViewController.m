//
//  ProjectTableViewController.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-26.
//
//

#import "ProjectTableViewController.h"
#import "ProjectApi.h"
#import "projectModel.h"
#import "LoginModel.h"
#import "ProjectStage.h"
#import "ProjectTableViewCell.h"
#import "MJRefresh.h"
#import "ConnectionAvailable.h"
#import "MBProgressHUD.h"
#import "ProgramDetailViewController.h"
@interface ProjectTableViewController ()

@end

@implementation ProjectTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"GurmukhiMN-Bold" size:19], NSFontAttributeName,
                                                                     nil]];
    
    //RightButton设置属性
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 41, 36.5)];
    [rightButton setBackgroundImage:[GetImagePath getImagePath:@"项目-首页_03a"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    [bgView setBackgroundColor:[UIColor clearColor]];
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake(15, 0, 169, 31)];
    [searchBtn setBackgroundImage:[GetImagePath getImagePath:@"项目-首页_08a"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(serachClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:searchBtn];
    
    UIImageView *searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(35, 8, 15, 15)];
    [searchImage setImage:[GetImagePath getImagePath:@"搜索结果_09a"]];
    [bgView addSubview:searchImage];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 120, 30)];
    label.textColor = [UIColor whiteColor];
    label.text = @"寻找项目，发现机会";
    label.font = [UIFont systemFontOfSize:12];
    [bgView addSubview:label];
    self.navigationItem.titleView = bgView;
    
    startIndex = 0;
    showArr = [[NSMutableArray alloc] init];
    [ProjectApi GetListWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            showArr = posts;
            [self.tableView reloadData];
        }
    } startIndex:startIndex noNetWork:nil];
    self.tableView.backgroundColor = RGBCOLOR(239, 237, 237);
    self.tableView.separatorStyle = NO;
    
    //集成刷新控件
    [self setupRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)serachClick{
     SearchViewController *searchView = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:searchView animated:YES];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    //[_tableView headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    if (![ConnectionAvailable isConnectionAvailable]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.removeFromSuperViewOnHide =YES;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"当前网络不可用，请检查网络连接！";
        hud.labelFont = [UIFont fontWithName:nil size:14];
        hud.minSize = CGSizeMake(132.f, 108.0f);
        [hud hide:YES afterDelay:3];
        [self.tableView footerEndRefreshing];
        [self.tableView headerEndRefreshing];
    }else{
        startIndex = 0;
        
        [ProjectApi GetListWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                [showArr removeAllObjects];
                showArr = posts;
                [self.tableView footerEndRefreshing];
                [self.tableView headerEndRefreshing];
                [self.tableView reloadData];
            }
        }startIndex:startIndex noNetWork:nil];
    }
}

- (void)footerRereshing
{
    if (![ConnectionAvailable isConnectionAvailable]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.removeFromSuperViewOnHide =YES;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"当前网络不可用，请检查网络连接！";
        hud.labelFont = [UIFont fontWithName:nil size:14];
        hud.minSize = CGSizeMake(132.f, 108.0f);
        [hud hide:YES afterDelay:3];
        [self.tableView footerEndRefreshing];
        [self.tableView headerEndRefreshing];
    }else{
        startIndex = startIndex +1;
        [ProjectApi GetListWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                [showArr addObjectsFromArray:posts];
                [self.tableView footerEndRefreshing];
                [self.tableView headerEndRefreshing];
                [self.tableView reloadData];
            }
        }startIndex:startIndex noNetWork:nil];
    }
}

-(void)rightBtnClick{
    TopicsTableViewController *topicsview = [[TopicsTableViewController alloc] init];
    [self.navigationController pushViewController:topicsview animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return showArr.count;
}

//push去展示页前将tabbar隐藏
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProgramDetailViewController* vc=[[ProgramDetailViewController alloc]init];
    projectModel *model = showArr[indexPath.row];
    vc.projectId = model.a_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"ProjectTableViewCell"];
    ProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    projectModel *model = showArr[indexPath.row];
    if(!cell){
        cell = [[ProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model fromView:@"project"];
    }
    cell.indexRow=indexPath.row;
    cell.delegate = self;
    cell.model = model;
    cell.selectionStyle = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 30;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 280;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 291.5, 50)];
        [bgView setBackgroundColor:RGBCOLOR(239, 237, 237)];
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 160, 20)];
        countLabel.font = [UIFont fontWithName:@"GurmukhiMN" size:12];
        countLabel.textColor = GrayColor;
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.text = [NSString stringWithFormat:@"共计%d条",showArr.count];
        [bgView addSubview:countLabel];
        return bgView;
    }
    return nil;
}

-(void)addProjectCommentView:(int)index{
    projectModel *model = showArr[index];
    PorjectCommentTableViewController *projectCommentView = [[PorjectCommentTableViewController alloc] init];
    projectCommentView.projectId = model.a_id;
    projectCommentView.projectName = model.a_projectName;
    [self.navigationController pushViewController:projectCommentView animated:YES];
}
@end
