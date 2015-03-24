//
//  ChatBaseViewController.m
//  ZhuZhan
//
//  Created by 孙元侃 on 15/3/5.
//
//

#import "ChatBaseViewController.h"
#import "HomePageViewController.h"
#import "AppDelegate.h"
#import "SearchBarTableViewController.h"

@interface ChatBaseViewController()
@property(nonatomic,strong)UIButton* rightBtn;
@property(nonatomic,strong)UIButton* leftBtn;

@property(nonatomic)BOOL searchBarIsTableViewHeader;

@property(nonatomic,strong)SearchBarTableViewController* searchBarTableViewController;

@property(nonatomic,weak)UIButton* searchBarBackBtn;
@property(nonatomic)BOOL searchBarIsAnimating;
@end

@implementation ChatBaseViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.leftBtnIsBack=YES;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.view.backgroundColor=[UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"GurmukhiMN-Bold" size:19], NSFontAttributeName,nil]];
}

//Navi相关
-(void)setRightBtnWithImage:(UIImage*)image{
    if (!_rightBtn) {
        _rightBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [_rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_rightBtn];
    }
    [_rightBtn setBackgroundImage:image forState:UIControlStateNormal];
}

-(void)setRightBtnWithText:(NSString*)text{
    if (!_rightBtn) {
        UIFont* font=[UIFont systemFontOfSize:15];
        _rightBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, [text boundingRectWithSize:CGSizeMake(9999, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width, 20)];
        [_rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _rightBtn.titleLabel.font=font;
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_rightBtn];
    }
    [_rightBtn setTitle:text forState:UIControlStateNormal];
}

-(void)rightBtnClicked{
    
}

-(void)setLeftBtnWithImage:(UIImage*)image{
    if (!_leftBtn) {
        _leftBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [_leftBtn setBackgroundImage:image forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_leftBtn];
    }else{
        [_leftBtn setBackgroundImage:image forState:UIControlStateNormal];
    }
}

-(void)setLeftBtnWithText:(NSString*)text{
    if (!_leftBtn) {
        UIFont* font=[UIFont systemFontOfSize:15];
        _leftBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, [text boundingRectWithSize:CGSizeMake(9999, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width, 20)];
        [_leftBtn addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _leftBtn.titleLabel.font=font;
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_leftBtn];
    }
    [_leftBtn setTitle:text forState:UIControlStateNormal];
}

-(void)leftBtnClicked{
    if (self.leftBtnIsBack) {
        if (self.needAnimaiton) {
            [self addAnimation];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//-(NSMutableArray *)models{
//    if (!_models) {
//        _models=[NSMutableArray array];
//    }
//    return _models;
//}

-(void)initTableView{
    CGFloat y=64;
    if (self.stageChooseView){
        y+=CGRectGetHeight(self.stageChooseView.frame);
    }
    if (self.searchBar&&!self.searchBarIsTableViewHeader) {
        y+=CGRectGetHeight(self.searchBar.frame);
    }
    
    CGFloat height=kScreenHeight-y;
    self.tableView=[[RKBaseTableView alloc]initWithFrame:CGRectMake(0, y, kScreenWidth, height) style:UITableViewStylePlain];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    if (self.searchBar&&!self.searchBarIsTableViewHeader) {
        [self.view insertSubview:self.tableView belowSubview:self.searchBar];
    }else if (self.stageChooseView){
        [self.view insertSubview:self.tableView belowSubview:self.stageChooseView];
    }else{
        [self.view addSubview:self.tableView];
    }
}

-(void)setUpSearchBarWithNeedTableView:(BOOL)needTableView isTableViewHeader:(BOOL)isTableViewHeader{
    self.searchBarIsTableViewHeader=isTableViewHeader;
    
    CGFloat y=64+(self.stageChooseView?CGRectGetHeight(self.stageChooseView.frame):0);
    self.searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, y, 320, 43)];
    self.searchBar.placeholder = @"搜索";
    self.searchBar.tintColor = [UIColor grayColor];
    self.searchBar.backgroundImage=[self imageWithColor:RGBCOLOR(223, 223, 223)];
    self.searchBar.delegate=self;
    
    if (!isTableViewHeader) {
        if (self.stageChooseView) {
            [self.view insertSubview:self.searchBar belowSubview:self.stageChooseView];
        }else{
            [self.view addSubview:self.searchBar];
        }
    }
    
    if (needTableView) {
        [self setUpSearchBarTableView];
    }
}

-(void)setUpSearchBarTableView{
    self.searchBarTableViewController=[[SearchBarTableViewController alloc]init];
    self.searchBarTableViewController.delegate=self;
}

-(void)setSearchBarTableViewBackColor:(UIColor*)color{
    self.searchBarTableViewController.view.backgroundColor=color;
    self.searchBarTableViewController.tableView.backgroundColor=color;
}

- (UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)addAnimation{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"rippleEffect";
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
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

//搜索框tableView
-(void)reloadSearchBarTableViewData{
    [self.searchBarTableViewController reloadSearchBarTableViewData];
}

//搜索框动画
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    if (!self.searchBarIsAnimating) {
        self.searchBarIsAnimating=YES;
        [self appearAnimation:searchBar];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    if (self.searchBarIsAnimating) {
        [self disappearAnimation:searchBar];
        self.searchBarIsAnimating=NO;
    }
}

-(void)appearAnimation:(UISearchBar *)searchBar{
    self.searchBar.showsCancelButton=YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    CGFloat height=65+CGRectGetHeight(self.stageChooseView.frame);
    UIView* view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, height)];
    self.searchBarAnimationBackView=view;
    self.searchBarAnimationBackView.alpha=0;
    self.searchBarAnimationBackView.backgroundColor=RGBCOLOR(223, 223, 223);
    [self.navigationController.view addSubview:self.searchBarAnimationBackView];
    
    UIButton* button=[[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.searchBar.frame)+64+CGRectGetHeight(self.stageChooseView.frame), kScreenWidth, CGRectGetHeight(self.view.frame))];
    button.backgroundColor=[UIColor blackColor];
    [button addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    button.alpha=0.5;
    [self.view addSubview:button];
    self.searchBarBackBtn=button;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.searchBarAnimationBackView.alpha=1;
        CGFloat ty=64-20+CGRectGetHeight(self.stageChooseView.frame);
        self.navigationController.view.transform=CGAffineTransformMakeTranslation(0, -ty);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)disappearAnimation:(UISearchBar *)searchBar{
    searchBar.text=@"";
    self.searchBar.showsCancelButton=NO;
    //self.navigationController.navigationBar.barTintColor=RGBCOLOR(85, 103, 166);
    [self searchBarTableViewDisppear];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.view.transform=CGAffineTransformIdentity;
        self.searchBarAnimationBackView.alpha=0;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.searchBarAnimationBackView removeFromSuperview];
        [self.searchBarBackBtn removeFromSuperview];
        [searchBar resignFirstResponder];
    }];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!self.searchBarTableViewController.view.superview) {
        [self searchBarTableViewAppear];
    }
    [searchBar resignFirstResponder];
}

-(void)searchBarTableViewAppear{
    self.searchBarTableViewController.view.transform=CGAffineTransformMakeTranslation(0, 64+self.searchBar.frame.size.height);
    [self.view addSubview:self.searchBarTableViewController.view];
}

-(void)searchBarTableViewDisppear{
    [self.searchBarTableViewController.view removeFromSuperview];
}

-(void)backBtnClicked{
    [self searchBarCancelButtonClicked:self.searchBar];
}

-(NSMutableArray *)sectionSelectedArray{
    if (!_sectionSelectedArray) {
        _sectionSelectedArray=[NSMutableArray array];
    }
    return _sectionSelectedArray;
}

-(BOOL)sectionSelectedArrayContainsSection:(NSInteger)section{
    NSString* sectionStr=[NSString stringWithFormat:@"%d",(int)section];
    return  [self.sectionSelectedArray containsObject:sectionStr];
}

-(BOOL)sectionViewClickedWithSection:(NSInteger)section{
    NSString* sectionStr=[NSString stringWithFormat:@"%d",(int)section];
    BOOL isContainsSection=[self.sectionSelectedArray containsObject:sectionStr];
    SEL action=isContainsSection?@selector(removeObject:):@selector(addObject:);
    [self.sectionSelectedArray performSelector:action withObject:sectionStr];
    return isContainsSection;
}

-(void)addKeybordNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybordWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)keybordWillChangeFrame:(NSNotification *)noti{
    NSNumber* duration=noti.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    CGRect keybordBounds=[noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat upHeight=kScreenHeight-keybordBounds.origin.y;

    [UIView animateWithDuration:[duration integerValue]  animations:^{
        self.view.transform=CGAffineTransformMakeTranslation(0, -upHeight);
    }];
}

-(void)touchesBeganInRKBaseTableView{
    [self.view endEditing:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self touchesBeganInRKBaseTableView];
}

-(void)initStageChooseViewWithStages:(NSArray*)stages numbers:(NSArray*)numbers{
    self.stageChooseView=[RKStageChooseView stageChooseViewWithStages:
                  stages numbers:numbers delegate:self];
    CGRect frame=self.stageChooseView.frame;
    frame.origin=CGPointMake(0, 64);
    self.stageChooseView.frame=frame;
    
    [self.view addSubview:self.stageChooseView];
}

-(void)initChatToolBar{
    self.chatToolBar=[ChatToolBar chatToolBar];
    self.chatToolBar.delegate=self;
    self.chatToolBar.center=CGPointMake(kScreenWidth*0.5, kScreenHeight-CGRectGetHeight(self.chatToolBar.frame)*.5);
    [self.view addSubview:self.chatToolBar];
    
    if (self.tableView) {
        CGRect frame=self.tableView.frame;
        frame.size.height-=CGRectGetHeight(self.chatToolBar.frame);
        self.tableView.frame=frame;
    }
}

-(void)chatToolBarSizeChangeWithHeight:(CGFloat)height{
    self.tableView.transform=CGAffineTransformMakeTranslation(0, [ChatToolBar orginChatToolBarHeight]-height);
}

-(void)dealloc{
    self.tableView.delegate=nil;
    self.tableView.dataSource=nil;
    self.searchBar.delegate=nil;
    self.searchBarTableViewController.delegate=nil;
}
@end
