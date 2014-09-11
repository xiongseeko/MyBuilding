//
//  PorjectCommentTableViewController.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-9-4.
//
//

#import "PorjectCommentTableViewController.h"
#import "CommentApi.h"
#import "ProjectCommentModel.h"
#import "UIViewController+MJPopupViewController.h"
#import "AppDelegate.h"
#import "HomePageViewController.h"
@interface PorjectCommentTableViewController ()

@end

@implementation PorjectCommentTableViewController
@synthesize projectId,projectName;
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
    //LeftButton设置属性
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 29, 28.5)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"icon_04.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"GurmukhiMN-Bold" size:19], NSFontAttributeName,
                                                                     nil]];
    
    //RightButton设置属性
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 30, 20)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"项目－评论列表_03a.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    _datasource = [NSMutableArray new];
    viewArr = [[NSMutableArray alloc] init];
    [CommentApi GetEntityCommentsWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            showArr = posts;
            for(int i=0; i<posts.count;i++){
                ProjectCommentModel *model = posts[i];
                projectCommentView = [[ProjectCommentView alloc] initWithCommentModel:model];
                [viewArr addObject:projectCommentView];
                [_datasource addObject:model.a_time];
            }
            [self.tableView reloadData];
        }
    } entityId:projectId entityType:@"Project"];
    
    //时间标签
    _timeScroller = [[ACTimeScroller alloc] initWithDelegate:self];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.backgroundColor = RGBCOLOR(239, 237, 237);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)leftBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClick{
    addCommentView = [[AddCommentViewController alloc] init];
    addCommentView.delegate = self;
    [self presentPopupViewController:addCommentView animationType:MJPopupViewAnimationFade flag:2];
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
    //隐藏tabBar
    AppDelegate* app=[AppDelegate instance];
    HomePageViewController* homeVC=(HomePageViewController*)app.window.rootViewController;
    [homeVC homePageTabBarHide];
}


//滚动是触发的事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_timeScroller scrollViewDidScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_timeScroller scrollViewDidEndDecelerating];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_timeScroller scrollViewWillBeginDragging];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [showArr count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return 55;
    }else{
        return [viewArr[indexPath.row-1] frame].size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        NSString *CellIdentifier = [NSString stringWithFormat:@"cell"];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.backgroundColor = RGBCOLOR(239, 237, 237);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(151.5, 10, 17, 17)];
        [imageView setImage:[UIImage imageNamed:@"项目－评论列表_03a-07"]];
        [cell.contentView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, 320, 20)];
        label.text = self.projectName;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor blueColor];
        [cell.contentView addSubview:label];
        return cell;
    }else{
        NSString *CellIdentifier = [NSString stringWithFormat:@"cell2"];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        if (cell.contentView.subviews.count) {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        [cell.contentView addSubview:viewArr[indexPath.row-1]];
        
        return cell;
    }
    return nil;
}

//时间标签
- (UITableView *)tableViewForTimeScroller:(ACTimeScroller *)timeScroller
{
    return [self tableView];
}
//传入时间标签的date
- (NSDate *)timeScroller:(ACTimeScroller *)timeScroller dateForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    if(indexPath.row !=0){
        return _datasource[[indexPath row]-1];
    }else{
        return nil;
    }
}

-(void)sureFromAddCommentWithComment:(NSString*)comment{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.projectId forKey:@"EntityId"];
    [dic setValue:[NSString stringWithFormat:@"%@",comment] forKey:@"CommentContents"];
    [dic setValue:@"Project" forKey:@"EntityType"];
    [dic setValue:@"f483bcfc-3726-445a-97ff-ac7f207dd888" forKey:@"CreatedBy"];
    [CommentApi AddEntityCommentsWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            ProjectCommentModel *model = [[ProjectCommentModel alloc] init];
            model.a_id = self.projectId;
            model.a_name = @"";
            model.a_imageUrl = @"";
            model.a_content = [NSString stringWithFormat:@"%@",comment];
            model.a_type = @"comment";
            model.a_time = [NSDate date];
            [showArr insertObject:model atIndex:0];
            projectCommentView = [[ProjectCommentView alloc] initWithCommentModel:model];
            [viewArr insertObject:projectCommentView atIndex:0];
            [_datasource insertObject:[NSDate date] atIndex:0];
            [self.tableView reloadData];
        }
    } dic:dic];
}

-(void)cancelFromAddComment{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
@end