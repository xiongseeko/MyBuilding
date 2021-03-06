//
//  ProductDetailViewController.m
//  ZhuZhan
//
//  Created by 孙元侃 on 14-9-3.
//
//

#import "ProductDetailViewController.h"
#import "ProductCommentView.h"
#import "AddCommentViewController.h"
#import "AppDelegate.h"
#import "UIViewController+MJPopupViewController.h"
#import "CommentApi.h"
#import "ACTimeScroller.h"
#import "HomePageViewController.h"
#import "AppDelegate.h"
#import "LoginSqlite.h"
#import "LoginViewController.h"
#import "ContactCommentModel.h"
#import "ACTimeScroller.h"
#import "LoginSqlite.h"
#import "MBProgressHUD.h"
#import "PersonalDetailViewController.h"
#import "CompanyDetailViewController.h"
#import "ConnectionAvailable.h"
#import "MBProgressHUD.h"
#import "ProductModel.h"
#import "LoginViewController.h"
#import "IsFocusedApi.h"
#import "LoadingView.h"
#import "MyTableView.h"
#import "MJRefresh.h"
@interface ProductDetailViewController ()<UITableViewDataSource,UITableViewDelegate,AddCommentDelegate,ACTimeScrollerDelegate,LoginViewDelegate>
@property(nonatomic,strong)MyTableView* tableView;

//所有model的a_id均为产品或动态自身的id,a_entityId是自身所属的id
@property(nonatomic,strong)ProductModel* productModel;//产品详情模型
@property(nonatomic,strong)ActivesModel* activesModel;//动态详情模型
@property(nonatomic,strong)PersonalCenterModel* personalModel;//个人中心评论

//@property(nonatomic,strong)NSString* activesEntityUrl;//动态详情模型url

@property(nonatomic,strong)UIView* mainView;//产品图片和产品介绍文字的superView

@property(nonatomic,strong)NSMutableArray* commentModels;//评论数组，元素为评论实体类
@property(nonatomic,strong)NSMutableArray* commentViews;//cell中的内容视图

@property(nonatomic,strong)AddCommentViewController* vc;

@property(nonatomic,strong)ACTimeScroller* timeScroller;
@property(nonatomic,strong)UILabel* noticeLabel;

//mainView部分
@property(nonatomic,strong)NSString* imageWidth;
@property(nonatomic,strong)NSString* imageHeight;
@property(nonatomic,strong)NSString* imageUrl;
@property(nonatomic,strong)NSString* userImageUrl;
@property(nonatomic,strong)NSString* content;
@property(nonatomic,strong)NSString* entityID;//动态或者产品自身的id
@property(nonatomic,strong)NSString* entityUrl;//获取动态时可能会用
@property(nonatomic,strong)NSString* userName;
@property(nonatomic,strong)NSString* category;//产品或动态的分类
@property(nonatomic,strong)NSString* createdBy;
@property(nonatomic,strong)NSString* userType;//产品或动态的

@property(nonatomic,strong)NSString* myName;//登录用户的用户昵称
@property(nonatomic,strong)NSString* myImageUrl;//登录用户的用户头像
@property(nonatomic,strong)NSString* isFocused;

@property(nonatomic,strong)LoadingView *loadingView;
@property(nonatomic,strong)UIButton *button;

@property(nonatomic)int startIndex;
@end

@implementation ProductDetailViewController
static NSString * const PSTableViewCellIdentifier = @"PSTableViewCellIdentifier";

-(NSString*)myName{
    if (!_myName) {
        _myName=[LoginSqlite getdata:@"userName"];
    }
    return _myName;
}

-(NSString*)myImageUrl{
    if (!_myImageUrl) {
        _myImageUrl=[LoginSqlite getdata:@"userImage"];
    }
    return _myImageUrl;
}

-(void)loadMyPropertyWithImgW:(NSString*)imgW imgH:(NSString*)imgH imgUrl:(NSString*)imgUrl userImgUrl:(NSString*)userImgUrl content:(NSString*)content entityID:(NSString*)entityID entityUrl:(NSString*)entityUrl userName:(NSString*)userName category:(NSString*)category createdBy:(NSString*)createdBy userType:(NSString*)userType{
    self.imageWidth=imgW;
    self.imageHeight=imgH;
    self.imageUrl=imgUrl;
    self.userImageUrl=userImgUrl;
    self.content=content;
    self.entityID=entityID;
    self.entityUrl=entityUrl;
    self.userName=userName;
    self.category=category;
    self.createdBy=createdBy;
    self.userType=userType;
    self.commentViews=[[NSMutableArray alloc]init];
}

-(instancetype)initWithProductModel:(ProductModel*)productModel{
    self=[super init];
    if (self) {
        self.productModel=productModel;
        [self loadMyPropertyWithImgW:productModel.a_imageWidth imgH:productModel.a_imageHeight imgUrl:productModel.a_originImageUrl userImgUrl:productModel.a_avatarUrl content:productModel.a_content entityID:productModel.a_id entityUrl:@"" userName:productModel.a_userName category:@"Product" createdBy:productModel.a_createdBy userType:productModel.a_userType];
    }
    return self;
}

-(instancetype)initWithActivesModel:(ActivesModel*)activesModel{
    self=[super init];
    if (self) {
        self.activesModel=activesModel;
//        [self loadMyPropertyWithImgW:activesModel.a_imageWidth imgH:activesModel.a_imageHeight imgUrl:[activesModel.a_category isEqualToString:@"Product"]?activesModel.a_productImage:activesModel.a_imageUrl userImgUrl:activesModel.a_avatarUrl content:activesModel.a_content entityID:[activesModel.a_category isEqualToString:@"Product"]?activesModel.a_entityId:activesModel.a_id entityUrl:activesModel.a_entityUrl userName:activesModel.a_userName category:activesModel.a_category createdBy:activesModel.a_createdBy userType:activesModel.a_userType];
        
        [self loadMyPropertyWithImgW:activesModel.a_imageWidth imgH:activesModel.a_imageHeight imgUrl:[activesModel.a_sourceCode isEqualToString:@"03"]?activesModel.a_bigProductImage:activesModel.a_bigImageUrl userImgUrl:activesModel.a_dynamicAvatarUrl content:activesModel.a_content entityID:[activesModel.a_sourceCode isEqualToString:@"03"]?activesModel.a_entityId:activesModel.a_id entityUrl:@"" userName:activesModel.a_dynamicLoginName category:activesModel.a_sourceCode createdBy:activesModel.a_dynamicLoginId userType:activesModel.a_dynamicUserType];
    }
    return self;
}

-(instancetype)initWithPersonalCenterModel:(PersonalCenterModel *)personalModel{
    self=[super init];
    if (self) {
//        self.personalModel=personalModel;
//        if([personalModel.a_category isEqualToString:@"Product"]){
//            self.productModel = [[ProductModel alloc] init];
//        }
//        [self loadMyPropertyWithImgW:personalModel.a_imageWidth imgH:personalModel.a_imageHeight imgUrl:personalModel.a_imageOriginalUrl userImgUrl:self.myImageUrl content:personalModel.a_content entityID:personalModel.a_entityId entityUrl:personalModel.a_entityUrl userName:self.myName category:personalModel.a_category createdBy:[LoginSqlite getdata:@"userId"] userType:personalModel.a_userType];
        self.personalModel=personalModel;
        if([personalModel.a_messageType isEqualToString:@"03"]){
            self.productModel = [[ProductModel alloc] init];
        }
        [self loadMyPropertyWithImgW:personalModel.a_imageWidth imgH:personalModel.a_imageHeight imgUrl:personalModel.a_imageOriginalUrl userImgUrl:self.myImageUrl content:personalModel.a_msgContent entityID:personalModel.a_messageSourceId entityUrl:@"" userName:self.myName category:personalModel.a_messageType createdBy:[LoginSqlite getdata:@"userId"] userType:personalModel.a_userType];
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self initNavi];
    
    self.startIndex = 0;

    [self initMyTableView];
    self.loadingView=[LoadingView loadingViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight) superView:self.view];

    //因为动态详情进来的产品model.content是评论而不是产品描述内容，所以先不出mainView，加载后会更新
    //暂时先取消，因为网络请求后会再次加载的，如果出现BUG，再次重新打开查看是否还存在BUG
    //if (!(self.activesModel&&[self.category isEqualToString:@"Product"])) {
       // [self getMainView];
    //}
    [self loadTimeScroller];
    [self firstNetWork];
    
    //集成刷新控件
    [self setupRefresh];
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
    self.startIndex = 0;
    [self firstNetWork];
}

- (void)footerRereshing
{
    [CommentApi GetEntityCommentsWithBlock:^(NSMutableArray *posts, NSError *error) {
        if (!error) {
            self.startIndex ++;
            if(posts.count !=0){
                [self.commentModels addObjectsFromArray:posts];
                [self.commentViews removeAllObjects];
                [self getTableViewContents];
                [self.tableView reloadData];
            }
        }else{
            if([ErrorCode errorCode:error] == 403){
                [LoginAgain AddLoginView:NO];
            }else{
                [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
                    [self firstNetWork];
                }];
            }
        }
        [self.tableView footerEndRefreshing];
    } entityId:self.entityID entityType:self.type startIndex:self.startIndex+1 noNetWork:^{
        [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
            [self firstNetWork];
        }];
    }];
}

//初始化竖直滚动导航的时间标示
-(void)loadTimeScroller{
    self.timeScroller = [[ACTimeScroller alloc] initWithDelegate:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:PSTableViewCellIdentifier];
}

-(void)firstNetWork{
    if([[LoginSqlite getdata:@"userId"] isEqualToString:@""]){
        [self getNetWorkData];
    }else{
        [IsFocusedApi GetIsFocusedListWithBlock:^(NSMutableArray *posts, NSError *error) {
            if (!error) {
                self.isFocused=[NSString stringWithFormat:@"%@",posts[0][@"isFocus"]];
                self.productModel.a_focusedNum=posts[0][@"focusNum"];
                [self initNavi];
                [self getNetWorkData];
            }else{
                if([ErrorCode errorCode:error] ==403){
                    [LoginAgain AddLoginView:NO];
                }else{
                    [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
                        [self firstNetWork];
                    }];
                }
            }
            [self.tableView headerEndRefreshing];
        } userId:[LoginSqlite getdata:@"userId"] targetId:self.entityID noNetWork:^{
            [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
                [self firstNetWork];
            }];
        }];
    }
}

-(void)removeMyLoadingView{
    [LoadingView removeLoadingView:self.loadingView];
    self.loadingView=nil;
}

//获取网络数据
-(void)getNetWorkData{
    NSLog(@"===>%@",self.type);
    self.startIndex = 0;
    [CommentApi GetEntityCommentsWithBlock:^(NSMutableArray *posts, NSError *error) {
        [self removeMyLoadingView];
        if (!error) {
            [self.commentModels removeAllObjects];
            [self.commentViews removeAllObjects];
            self.commentModels=posts;
            [self getTableViewContents];
            [self myTableViewReloadData];
        }else{
            if([ErrorCode errorCode:error] == 403){
                [LoginAgain AddLoginView:NO];
            }else{
                [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
                    [self firstNetWork];
                }];
            }
        }
    } entityId:self.entityID entityType:self.type startIndex:0 noNetWork:^{
        [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
            [self firstNetWork];
        }];
    }];
}

//获得上方主要显示的图文内容
-(void)getMainView{
    if (self.productModel||(self.personalModel&&[self.category isEqualToString:@"Product"])) {
        [self getProductMainView];
    }else if (self.activesModel||(self.personalModel||!([self.category isEqualToString:@"Product"]))){
        [self getActiveMainView];
    }
}

-(void)getProductMainView{
    //self.content=@"顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶顶";
    //self.userName=@"一二三四五六七八九十一二三四五六七八九十";
    //self.content=@"";
//    self.imageUrl=@"dsadsa";
    self.mainView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView* forCornerView=[[UIView alloc]initWithFrame:CGRectZero];
    [self.mainView addSubview:forCornerView];
    forCornerView.layer.cornerRadius=2;
    forCornerView.layer.masksToBounds=YES;
    forCornerView.backgroundColor=[UIColor whiteColor];
    
    CGFloat height=0;
    
    UIImageView *imageView;
    //动态图像
    if(![self.imageUrl isEqualToString:@""]){
        imageView = [[UIImageView alloc] init];
        imageView.backgroundColor=RGBCOLOR(215, 216, 215);
        if([self.imageHeight floatValue]/[self.imageWidth floatValue]*310<50){
            imageView.frame = CGRectMake(0, 0, 310,50);
             height+=50;
        }else{
            imageView.frame = CGRectMake(0, 0, 310,[self.imageHeight floatValue]/[self.imageWidth floatValue]*310);
            height+=imageView.frame.size.height;
        }
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.imageUrl]] placeholderImage:[GetImagePath getImagePath:@"product_default_detail"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [forCornerView addSubview:imageView];
    }
    
    //产品名称
    NSString* productNameStr=@"产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称产品名称";
    productNameStr=self.productModel.a_name;
    CGFloat tempHeight=0;
    UIFont* productNameFont=[UIFont systemFontOfSize:16];
    CGFloat productNameWidth=[self.imageUrl isEqualToString:@""]?250:290;
    CGFloat productNameAreaHieght=[productNameStr boundingRectWithSize:CGSizeMake(productNameWidth, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:productNameFont} context:nil].size.height;
    UIView* productNameArea=[[UIView alloc]initWithFrame:CGRectMake(0, height, 310, productNameAreaHieght+3)];
    productNameArea.backgroundColor=[UIColor whiteColor];
    [forCornerView addSubview:productNameArea];
    UILabel* productNameLabel=[[UILabel alloc]initWithFrame:CGRectMake([self.imageUrl isEqualToString:@""]?60:10, 3, productNameWidth, productNameAreaHieght)];
    productNameLabel.text=productNameStr;
    productNameLabel.font=productNameFont;
    productNameLabel.textColor=BlueColor;
    productNameLabel.numberOfLines=0;
    [productNameArea addSubview:productNameLabel];
    tempHeight+=productNameLabel.frame.size.height+3;
    
    //用户名称
    UILabel* userNameLabel;
    if (!([self.imageUrl isEqualToString:@""]&&![self.content isEqualToString:@""])) {
        CGFloat userNameLabelWidth=productNameWidth;
        if ([self.imageUrl isEqualToString:@""]) {
            userNameLabelWidth-=50;
        }
        UIFont* nameFont=[UIFont systemFontOfSize:14];
        
        CGFloat userNameLabelHeight=[self.userName boundingRectWithSize:CGSizeMake(userNameLabelWidth, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:nameFont} context:nil].size.height;
        
        userNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(productNameLabel.frame.origin.x, productNameLabel.frame.origin.y+productNameLabel.frame.size.height+3, userNameLabelWidth, userNameLabelHeight)];
        userNameLabel.numberOfLines=0;
        userNameLabel.text=self.userName;
        userNameLabel.textColor=BlueColor;
        userNameLabel.font=nameFont;
        [productNameArea addSubview:userNameLabel];
        
        
        tempHeight+=userNameLabel.frame.size.height+3;
    }
    
    if ([self.imageUrl isEqualToString:@""]) {
        tempHeight=tempHeight<=45?45:tempHeight;
    }
    productNameArea.frame=CGRectMake(0, height, 310, tempHeight);
    height+=productNameArea.frame.size.height;
    
    
    
    UIView* contentTotalView;
    //动态描述
    if (![self.content isEqualToString:@""]) {
        UILabel* contentTextView = [[UILabel alloc] init];
        contentTextView.numberOfLines =0;
        UIFont * tfont = [UIFont systemFontOfSize:14];
        contentTextView.font = tfont;
        contentTextView.textColor = [UIColor blackColor];
        contentTextView.lineBreakMode =NSLineBreakByCharWrapping ;
        
        NSString * text;
        if ([self.imageUrl isEqualToString:@""]&&![self.content isEqualToString:@""]) {
            //用户名颜色
            text = [NSString stringWithFormat:@"%@：%@",self.userName,self.content];
            NSMutableAttributedString* attributedText=[[NSMutableAttributedString alloc]initWithString:text];
            NSRange range=NSMakeRange(0, self.userName.length+1);
            [attributedText addAttributes:@{NSForegroundColorAttributeName:BlueColor} range:range];
            [attributedText addAttributes:@{NSFontAttributeName:tfont} range:NSMakeRange(0, text.length)];
            
            //动态文字内容
            contentTextView.attributedText=attributedText;
        }else{
            text=self.content;
            contentTextView.text=text;
        }
        
        //给一个比较大的高度，宽度不变
        CGSize size =CGSizeMake(290,CGFLOAT_MAX);
        // 获取当前文本的属性
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
        //ios7方法，获取文本需要的size，限制宽度
        CGSize actualsize =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        contentTextView.frame =CGRectMake(10,5, actualsize.width, actualsize.height);
        
        contentTotalView=[[UIView alloc]initWithFrame:CGRectMake(0, height, 310, imageView?contentTextView.frame.size.height+20-17:contentTextView.frame.size.height+20+40-5)];
        [contentTotalView addSubview:contentTextView];
        [forCornerView addSubview:contentTotalView];
        height+=contentTotalView.frame.size.height;
    }
    
    //评论图标
    //初始化tempHeight
    tempHeight=0;
    BOOL isNoImageNoContent=[self.imageUrl isEqualToString:@""]&&[self.content isEqualToString:@""];
    BOOL isNoImageHasContent=[self.imageUrl isEqualToString:@""]&&![self.content isEqualToString:@""];
    if (isNoImageNoContent) {
        tempHeight=userNameLabel.frame.origin.y+40;
        
        CGRect frame=productNameArea.frame;
        frame.size.height+=(40-userNameLabel.frame.size.height);
        height+=(40-userNameLabel.frame.size.height);
        productNameArea.frame=frame;
    }else if (isNoImageHasContent){
        CGFloat extraReduceHeight=15;
        tempHeight=imageView?imageView.frame.origin.y+imageView.frame.size.height:height-extraReduceHeight;
        height-=extraReduceHeight;
    }else{
        tempHeight=imageView?imageView.frame.origin.y+imageView.frame.size.height:height;
    }
    
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commentBtn.frame = CGRectMake(235, tempHeight-40, 65, 29);
    [commentBtn setImage:[GetImagePath getImagePath:@"addComment"] forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(chooseComment:) forControlEvents:UIControlEventTouchUpInside];
    [isNoImageNoContent?productNameArea:forCornerView addSubview:commentBtn];
    
    //用户头像
    BOOL isPersonal = [self.userType isEqualToString:@"Personal"];
    tempHeight=imageView?imageView.frame.origin.y:productNameArea.frame.origin.y;
    UIImageView* userImageView = [[UIImageView alloc] init];
    userImageView.layer.masksToBounds = YES;
    userImageView.layer.cornerRadius = isPersonal?20:3;
    userImageView.frame=CGRectMake(5,tempHeight+5,40,40);
    [forCornerView addSubview:userImageView];
    
    UIButton* btn=[[UIButton alloc]initWithFrame:userImageView.frame];
    btn.tag=0;
    [btn addTarget:self action:@selector(chooseUserImage:) forControlEvents:UIControlEventTouchUpInside];
    [forCornerView addSubview:btn];
    NSLog(@"a_focusedNum==>%@",self.productModel.a_focusedNum);
    height+=5;
    self.noticeLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, height, 100, 20)];
    self.noticeLabel.text=[NSString stringWithFormat:@"%@ 关注",self.productModel.a_focusedNum];
    self.noticeLabel.textColor=RGBCOLOR(141, 196, 62);
    self.noticeLabel.font=[UIFont systemFontOfSize:14];
    [forCornerView addSubview:self.noticeLabel];
    height+=self.noticeLabel.frame.size.height;
    [userImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.userImageUrl]] placeholderImage:[GetImagePath getImagePath:isPersonal?@"默认图_用户头像_卡片头像":@"默认图_公司头像_卡片头像"]];
    [forCornerView addSubview:userImageView];
    
    //调节有图无文字时候的下方留白高度
    //BOOL isHasImageNoContent=[self.content isEqualToString:@""]&&![self.imageUrl isEqualToString:@""];
    //if (isHasImageNoContent) {
    CGRect tempFrame=productNameArea.frame;
    tempFrame.size.height+=8;
    productNameArea.frame=tempFrame;
    height+=8;
    //}
    
    //设置总的view的frame
    forCornerView.frame=CGRectMake(5, 5, 310, height);
    height+=5;
    
    //与下方tableView的分割部分
    if (self.commentViews.count) {
        UIImage* separatorImage=[GetImagePath getImagePath:@"动态详情_14a"];
        CGRect frame=CGRectMake(0, height, separatorImage.size.width, separatorImage.size.height);
        UIImageView* separatorImageView=[[UIImageView alloc]initWithFrame:frame];
        separatorImageView.image=separatorImage;
        [self.mainView addSubview:separatorImageView];
        
        height+=frame.size.height;
    }
    
    //设置总的frame
    self.mainView.frame = CGRectMake(0, 0, 320, height);
    [self.mainView setBackgroundColor:RGBCOLOR(235, 235, 235)];
}

-(void)getActiveMainView{
    self.mainView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView* forCornerView=[[UIView alloc]initWithFrame:CGRectZero];
    [self.mainView addSubview:forCornerView];
    forCornerView.layer.cornerRadius=2;
    forCornerView.layer.masksToBounds=YES;
    
    CGFloat height=0;
    UIImageView *imageView;
    //动态图像
    if(![self.imageUrl isEqualToString:@""]){
        imageView = [[UIImageView alloc] init];
        imageView.backgroundColor=RGBCOLOR(215, 216, 215);
        if([self.imageHeight floatValue]/[self.imageWidth floatValue]*310<50){
            imageView.frame = CGRectMake(0, 0, 310,50);
            //imageView.contentMode = UIViewContentModeScaleAspectFit;
            height+=50;
        }else{
            imageView.frame = CGRectMake(0, 0, 310,[self.imageHeight floatValue]/[self.imageWidth floatValue]*310);
            height+=imageView.frame.size.height;
        }
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.imageUrl]] placeholderImage:[GetImagePath getImagePath:@"默认图_动态详情"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [forCornerView addSubview:imageView];
    }
    UIView* contentTotalView;
    //动态描述
    if (![self.content isEqualToString:@""]) {
        UILabel* contentTextView = [[UILabel alloc] init];
        contentTextView.numberOfLines =0;
        UIFont * tfont = [UIFont systemFontOfSize:14];
        contentTextView.font = tfont;
        contentTextView.textColor = [UIColor blackColor];
        contentTextView.lineBreakMode =NSLineBreakByCharWrapping ;
        
        //用户名颜色
        NSString * text = [NSString stringWithFormat:@"%@：%@",self.userName,self.content];
        NSMutableAttributedString* attributedText=[[NSMutableAttributedString alloc]initWithString:text];
        NSRange range=NSMakeRange(0, self.userName.length+1);
        [attributedText addAttributes:@{NSForegroundColorAttributeName:BlueColor} range:range];
        [attributedText addAttributes:@{NSFontAttributeName:tfont} range:NSMakeRange(0, text.length)];
        
        //动态文字内容
        contentTextView.attributedText=attributedText;
        
        BOOL imageUrlExist=![self.imageUrl isEqualToString:@""];
        //给一个比较大的高度，宽度不变
        CGSize size =CGSizeMake(imageUrlExist?290:250,CGFLOAT_MAX);
        // 获取当前文本的属性
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
        //ios7方法，获取文本需要的size，限制宽度
        CGSize actualsize =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        contentTextView.frame =CGRectMake(imageUrlExist?10:60,10, actualsize.width, actualsize.height);
        
        contentTotalView=[[UIView alloc]initWithFrame:CGRectMake(0, height, 310, imageView?contentTextView.frame.size.height+20:contentTextView.frame.size.height+20+40)];
        contentTotalView.backgroundColor=[UIColor whiteColor];
        [contentTotalView addSubview:contentTextView];
        [forCornerView addSubview:contentTotalView];
        height+=contentTotalView.frame.size.height;
    }
    
    
    //评论图标
    CGFloat tempHeight=imageView?imageView.frame.origin.y+imageView.frame.size.height:height;
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commentBtn.frame = CGRectMake(235, tempHeight-40, 65, 29);
    [commentBtn setImage:[GetImagePath getImagePath:@"addComment"] forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(chooseComment:) forControlEvents:UIControlEventTouchUpInside];
    [forCornerView addSubview:commentBtn];
    NSLog(@"frame=%@",NSStringFromCGRect(commentBtn.frame));
    //commentBtn.center=forCornerView.center;

    //用户头像
    BOOL isPersonal = [self.userType isEqualToString:@"Personal"];
    tempHeight=imageView?imageView.frame.origin.y:contentTotalView.frame.origin.y;
    UIImageView* userImageView = [[UIImageView alloc] init];
    userImageView.layer.masksToBounds = YES;
    userImageView.layer.cornerRadius = isPersonal?20:3;
    userImageView.frame=CGRectMake(5,tempHeight+5,40,40);
    [forCornerView addSubview:userImageView];
    
    UIButton* btn=[[UIButton alloc]initWithFrame:userImageView.frame];
    btn.tag=0;
    [btn addTarget:self action:@selector(chooseUserImage:) forControlEvents:UIControlEventTouchUpInside];
    [forCornerView addSubview:btn];
    [userImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.userImageUrl]] placeholderImage:[GetImagePath getImagePath:isPersonal?@"默认图_用户头像_卡片头像":@"默认图_公司头像_卡片头像"]];
    //[forCornerView addSubview:userImageView];
    
    //设置总的view的frame
    forCornerView.frame=CGRectMake(5, 5, 310, height-5);
    
    //与下方tableView的分割部分
    if (self.commentViews.count) {
        UIImage* separatorImage=[GetImagePath getImagePath:@"动态详情_14a"];
        CGRect frame=CGRectMake(0, height, separatorImage.size.width, separatorImage.size.height);
        UIImageView* separatorImageView=[[UIImageView alloc]initWithFrame:frame];
        separatorImageView.image=separatorImage;
        [self.mainView addSubview:separatorImageView];
        
        height+=frame.size.height;
    }
    
    //设置总的frame
    self.mainView.frame = CGRectMake(0, 0, 320, height);
    [self.mainView setBackgroundColor:RGBCOLOR(235, 235, 235)];
}

-(void)myTableViewReloadData{
    [self getMainView];
    [self.tableView reloadData];
}

-(void)getTableViewContents{
    for (int i=0; i<self.commentModels.count; i++) {
        ContactCommentModel* model=self.commentModels[i];
        ProductCommentView* view=[[ProductCommentView alloc]initWithCommentImageUrl:model.a_avatarUrl userName:model.a_userName commentContent:model.a_commentContents creatBy:model.a_createdBy needRound:model.a_isPersonal];
        [self.commentViews addObject:view];
    }
}

-(void)chooseComment:(UIButton*)button{
    NSString *deviceToken = [LoginSqlite getdata:@"token"];
    //判断是否有token,没有则进登录界面
    if ([deviceToken isEqualToString:@""]) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.view.window.rootViewController presentViewController:nv animated:YES completion:nil];
    }else{
        self.vc=[[AddCommentViewController alloc]init];
        self.vc.delegate=self;
        [self presentPopupViewController:self.vc animationType:MJPopupViewAnimationFade flag:2];
    }
}
//=============================================================
//ACTimeScrollerDelegate
//=============================================================
- (UITableView *)tableViewForTimeScroller:(ACTimeScroller *)timeScroller{
    return self.tableView;
}
- (NSDate *)timeScroller:(ACTimeScroller *)timeScroller dateForCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    // NSLog(@"index==%@,%d",cell.contentView.subviews,indexPath.row);
    if (!indexPath.row) {
        timeScroller.hidden=YES;
        return [NSDate date];
    }else{
        timeScroller.hidden=NO;
        return [self.commentModels[indexPath.row-1] a_time];
    }
}

//滚动时触发的事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_timeScroller scrollViewDidScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_timeScroller scrollViewDidEndDecelerating];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_timeScroller scrollViewWillBeginDragging];
}
//=============================================================
//AddCommentDelegate
//=============================================================
//点击添加评论并点取消的回调方法
-(void)cancelFromAddComment{
    NSLog(@"cancelFromAddComment");
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

// "EntityId": ":entity ID", （项目，产品，公司，动态等）
// "entityType": ":”entityType", Personal,Company,Project,Product 之一
// "CommentContents": "评论内容",
// "CreatedBy": ":“评论人"
// }
//点击添加评论并点确认的回调方法
-(void)sureFromAddCommentWithComment:(NSString *)comment{
    NSLog(@"sureFromAddCommentWithCommentModel:");
    if ([self.category isEqualToString:@"Product"]) {
        [self addProductComment:comment];
    }else{
        [self addActivesComment:comment];
    }
}

//post完成之后的操作
-(void)finishAddComment:(NSString*)comment aid:(NSString *)aid{
    [self addTableViewContentWithContent:comment aid:aid];
    [self myTableViewReloadData];
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

//添加动态详情的评论
-(void)addActivesComment:(NSString*)comment{
    [CommentApi AddEntityCommentsWithBlock:^(NSMutableArray *posts, NSError *error) {
        [self.vc finishNetWork];
        if(!error){
            [self finishAddComment:comment aid:posts[0]];
            if ([self.delegate respondsToSelector:@selector(finishAddCommentFromDetailWithPosts:)]) {
                //[self.delegate finishAddCommentFromDetailWithPosts:posts];
            }
        }else{
            if([ErrorCode errorCode:error] == 403){
                [LoginAgain AddLoginView:NO];
            }else{
                [ErrorCode alert];
            }
        }
    } dic:[@{@"paramId":self.entityID,@"content":comment,@"commentType":@"03"} mutableCopy] noNetWork:^{
        [ErrorCode alert];
    }];
}

//添加产品详情的评论
-(void)addProductComment:(NSString*)comment{
    [CommentApi AddEntityCommentsWithBlock:^(NSMutableArray *posts, NSError *error) {
        [self.vc finishNetWork];
        if (!error) {
            [self finishAddComment:comment aid:posts[0]];
        }else{
            if([ErrorCode errorCode:error] == 403){
                [LoginAgain AddLoginView:NO];
            }else{
                [ErrorCode alert];
            }
        }
    } dic:[@{@"paramId":self.entityID,@"commentType":@"01",@"content":comment} mutableCopy] noNetWork:^{
        [ErrorCode alert];
    }];
}

//给tableView添加数据
-(void)addTableViewContentWithContent:(NSString*)content aid:(NSString *)aid{
    ProductCommentView* view=[[ProductCommentView alloc]initWithCommentImageUrl:self.myImageUrl userName:self.myName commentContent:content creatBy:self.createdBy needRound:[[LoginSqlite getdata:@"userType"] isEqualToString:@"Personal"]];

    ContactCommentModel* model=[[ContactCommentModel alloc]initWithID:aid entityID:nil createdBy:[LoginSqlite getdata:@"userId"] userName:self.myName commentContents:content avatarUrl:self.myImageUrl time:[NSDate date]];
    
    [self.commentModels insertObject:model atIndex:0];
    [self.commentViews insertObject:view atIndex:0];
}
//=============================================================
//UITableViewDataSource,UITableViewDelegate
//=============================================================
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentViews.count+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row?[self.commentViews[indexPath.row-1] frame].size.height:self.mainView.frame.size.height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
        if (cell.contentView.subviews.count) {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        [cell.contentView addSubview:self.mainView];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        
        UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"myCell"];
        if (!cell) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
        }
        
        if (cell.contentView.subviews.count) {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        [cell.contentView addSubview:self.commentViews[indexPath.row-1]];
        
        CGFloat height=[cell.contentView.subviews.lastObject frame].size.height;
        
        //第一个cell,添加下方长方形区域,遮盖圆角
        if (indexPath.row==1) {
            [cell.contentView.subviews.lastObject layer].cornerRadius=3;
            if (indexPath.row!=self.commentViews.count) {
                UIView* view=[self getCellSpaceView];
                view.center=CGPointMake(160, height-5);
                [cell.contentView insertSubview:view atIndex:0];
            }
            
        //最后一个cell,添加上方长方形区域,遮盖圆角
        }else if (indexPath.row==self.commentViews.count){
            [cell.contentView.subviews.lastObject layer].cornerRadius=3;
            UIView* view=[self getCellSpaceView];
            view.center=CGPointMake(160, 5);
            [cell.contentView insertSubview:view atIndex:0];

        //其他cell,处理圆角
        }else{
            if ([cell.contentView.subviews.lastObject layer].cornerRadius>0) {
                [cell.contentView.subviews.lastObject layer].cornerRadius=0;
            }
        }
        
        //处理分割线
        if (indexPath.row!=self.commentViews.count) {
            UIView* separatorLine=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 310, 1)];
            separatorLine.backgroundColor=RGBCOLOR(229, 229, 229);
            separatorLine.center=CGPointMake(160, height-.5);
            [cell.contentView addSubview:separatorLine];
        }
        cell.backgroundColor=[UIColor clearColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        //使头像可以被点击
        UIButton* btn=[[UIButton alloc]initWithFrame:CGRectMake(15, 15, 37, 37)];
        btn.tag=indexPath.row;
        [btn addTarget:self action:@selector(chooseUserImage:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        
        ContactCommentModel* commentModel=self.commentModels[indexPath.row-1];
        ProductCommentView *view = self.commentViews[indexPath.row-1];
        if([commentModel.a_createdBy isEqualToString:[LoginSqlite getdata:@"userId"]]){
            UIImageView *delImage = [[UIImageView alloc] initWithFrame:CGRectMake(280, (view.frame.size.height-20)/2, 21, 20)];
            delImage.image = [GetImagePath getImagePath:@"delComment"];
            [cell.contentView addSubview:delImage];
            
            UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            delBtn.frame = CGRectMake(270, delImage.frame.origin.y-10, 40, 40);
            //[delBtn setBackgroundColor:[UIColor yellowColor]];
            [delBtn addTarget:self action:@selector(delComment:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:delBtn];
        }
        return cell;
    }
}
/**
 if([[LoginSqlite getdata:@"userType"] isEqualToString:@"Company"]){
 CompanyCenterViewController *companyVC = [[CompanyCenterViewController alloc] init];
 [self.navigationController pushViewController:companyVC animated:YES];
 }else{
 AccountViewController *accountVC = [[AccountViewController alloc] init];
 [self.navigationController pushViewController:accountVC animated:YES];
 }
 */
-(void)chooseUserImage:(UIButton*)btn{
    if([btn.tag?[self.commentModels[btn.tag-1] a_createdBy]:self.createdBy isEqualToString:[LoginSqlite getdata:@"userId"]]){
        return;
    }
    
    if ([btn.tag?[self.commentModels[btn.tag-1] a_userType]:self.userType isEqualToString:@"Personal"]) {
        PersonalDetailViewController* vc=[[PersonalDetailViewController alloc]init];
        vc.contactId=btn.tag?[self.commentModels[btn.tag-1] a_createdBy]:self.createdBy;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        CompanyDetailViewController* vc=[[CompanyDetailViewController alloc]init];
        vc.companyId=btn.tag?[self.commentModels[btn.tag-1] a_createdBy]:self.createdBy;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(UIView*)getCellSpaceView{
    UIView* view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 310, 10)];
    view.backgroundColor=[UIColor whiteColor];
    return view;
}

//=============================================================
//=============================================================
//=============================================================
-(void)initMyTableView{
    self.tableView=[[MyTableView alloc]initWithFrame:CGRectMake(0, 0, 320, kScreenHeight) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor=RGBCOLOR(235, 235, 235);
    [self.view addSubview:self.tableView];
}

-(void)initNavi{
    UIButton* button=[[UIButton alloc]initWithFrame:CGRectMake(0,5,25,22)];
    [button setImage:[GetImagePath getImagePath:@"013"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:button];
    
    if([self.category isEqualToString:@"Product"] ){
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setTitle:[self.isFocused isEqualToString:@"1"]?@"取消关注":@"加关注" forState:UIControlStateNormal];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [rightButton setFrame:CGRectMake(0, 0, 70, 44)];
        [rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
    }
}

-(void)back{
    self.tableView.delegate=nil;
    self.tableView.dataSource=nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)rightBtnClick{
    if(![[LoginSqlite getdata:@"userId"] isEqualToString:@""]){
        [self addNotice];
    }else{
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.needDelayCancel=YES;
        loginVC.delegate = self;
        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.view.window.rootViewController presentViewController:nv animated:YES completion:nil];
    }
}

- (void)addNotice{
    if (![ConnectionAvailable isConnectionAvailable]) {
        [MBProgressHUD myShowHUDAddedTo:self.view animated:YES];
        return;
    }
    
    if([self.isFocused isEqualToString:@"0"]){
        NSLog(@"关注");
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:self.entityID forKey:@"targetId"];
        [dic setObject:@"04" forKey:@"targetCategory"];
        [IsFocusedApi AddFocusedListWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"关注成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                self.isFocused = @"1";
                self.productModel.a_focusedNum = posts[0][@"focusNum"];
                self.noticeLabel.text=[NSString stringWithFormat:@"%@ 关注",self.productModel.a_focusedNum];
                [self initNavi];
                NSLog(@"关注数===》%@",posts[0][@"focusNum"]);
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
    }else{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:self.entityID forKey:@"targetId"];
        [dic setObject:@"04" forKey:@"targetCategory"];
        [IsFocusedApi AddFocusedListWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"取消关注成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                self.isFocused = @"0";
                self.productModel.a_focusedNum = posts[0][@"focusNum"];
                self.noticeLabel.text=[NSString stringWithFormat:@"%@ 关注",self.productModel.a_focusedNum];
                [self initNavi];
                NSLog(@"关注数===》%@",posts[0][@"focusNum"]);
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
}

-(void)loginCompleteWithDelayBlock:(void (^)())block{
    [IsFocusedApi GetIsFocusedListWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            self.isFocused=[NSString stringWithFormat:@"%@",posts[0][@"isFocus"]];
            self.productModel.a_focusedNum=posts[0][@"focusNum"];
            if (block) {
                block();
            }
        }else{
            [LoginAgain AddLoginView:NO];
        }
    } userId:[LoginSqlite getdata:@"userId"] targetId:self.entityID noNetWork:nil];
}

-(void)delComment:(UIButton *)button{
    self.button = button;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否删除评论" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        UITableViewCell * cell = (UITableViewCell *)[[self.button superview] superview];
        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        ContactCommentModel *model = self.commentModels[path.row-1];
        [CommentApi DelEntityCommentsWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                [self.commentModels removeObjectAtIndex:path.row-1];
                [self.commentViews removeObjectAtIndex:path.row-1];
                NSArray *indexPaths = [NSArray arrayWithObject:path];
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                if(self.commentModels.count==0){
                    [self myTableViewReloadData];
                }
            }else{
                if([ErrorCode errorCode:error] == 403){
                    [LoginAgain AddLoginView:NO];
                }else{
                    [ErrorCode alert];
                }
            }
        } dic:[@{@"commentId":model.a_id,@"commentType":self.type} mutableCopy] noNetWork:^{
            [ErrorCode alert];
        }];
    }
}
@end
