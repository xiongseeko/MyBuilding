//
//  DemandListSearchController.m
//  ZhuZhan
//
//  Created by 孙元侃 on 15/3/23.
//
//

#import "DemandListSearchController.h"
#import "AskPriceApi.h"
#import "AskPriceViewCell.h"
#import "AskPriceDetailViewController.h"
#import "QuotesDetailViewController.h"
@interface DemandListSearchController ()
@property(nonatomic,strong)NSString *statusStr;
@property(nonatomic,strong)NSString *otherStr;
@property(nonatomic,strong)NSMutableArray* models;
@end

@implementation DemandListSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.statusStr = @"";
    self.otherStr = @"-1";
    [self setUpSearchBarWithNeedTableView:YES isTableViewHeader:NO];
    [self setSearchBarTableViewBackColor:AllBackDeepGrayColor];
    [self.searchBar becomeFirstResponder];
    [self loadList];
}

-(void)loadList{
    [AskPriceApi GetAskPriceWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            self.models = posts[0];
            [self.tableView reloadData];
        }
    } status:self.statusStr startIndex:0 other:self.otherStr keyWorks:@"" noNetWork:nil];
}

-(NSInteger)searchBarNumberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)searchBarTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.models.count;
}
-(CGFloat)searchBarTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    AskPriceModel *model = self.models[indexPath.row];
    return [AskPriceViewCell carculateTotalHeightWithContents:@[model.a_invitedUser,model.a_productBigCategory,model.a_productCategory,model.a_remark]];
}

-(UITableViewCell *)searchBarTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AskPriceViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell=[[AskPriceViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.clipsToBounds=YES;
    }
    AskPriceModel *model = self.models[indexPath.row];
    cell.contents=@[model.a_invitedUser,model.a_productBigCategory,model.a_productCategory,model.a_remark,model.a_category,model.a_tradeStatus,model.a_tradeCode];
    return cell;
}

-(void)searchBarTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AskPriceModel *model = self.models[indexPath.row];
    if([model.a_category isEqualToString:@"0"]){
        NSLog(@"自己发");
        AskPriceDetailViewController *view = [[AskPriceDetailViewController alloc] init];
        view.askPriceModel = model;
        [self.navigationController pushViewController:view animated:YES];
    }else{
        NSLog(@"别人发");
        QuotesDetailViewController *view = [[QuotesDetailViewController alloc] init];
        view.askPriceModel = model;
        [self.navigationController pushViewController:view animated:YES];
    }
    self.searchBarAnimationBackView.hidden=YES;
    return;
//    [AskPriceApi GetAskPriceDetailsWithBlock:^(NSMutableArray *posts, NSError *error) {
//        if(!error){
//            if(posts.count !=0){
//                QuotesModel *quotesModel = posts[0];
//                NSLog(@"%@",quotesModel.a_loginName);
//                [AskPriceApi GetQuotesListWithBlock:^(NSMutableArray *posts, NSError *error) {
//                    if(!error){
//                        
//                    }
//                } providerId:quotesModel.a_loginId tradeCode:model.a_tradeCode startIndex:0 noNetWork:nil];
//            }
//        }
//    } tradeId:model.a_id noNetWork:nil];
}

-(NSMutableArray *)models{
    if (!_models) {
        _models=[NSMutableArray array];
    }
    return _models;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.navigationController popViewControllerAnimated:YES];
    [self disappearAnimation:searchBar];
}

-(void)disappearAnimation:(UISearchBar *)searchBar{
    self.navigationController.view.transform=CGAffineTransformMakeTranslation(0, 0);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.searchBarAnimationBackView removeFromSuperview];
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
    
    [UIView animateWithDuration:0.3 animations:^{
        self.searchBarAnimationBackView.alpha=1;
        CGFloat ty=64-20+CGRectGetHeight(self.stageChooseView.frame);
        self.navigationController.view.transform=CGAffineTransformMakeTranslation(0, -ty);
    } completion:^(BOOL finished) {
        
    }];
}
@end
