//
//  ChooseContactsViewController.m
//  ZhuZhan
//
//  Created by 孙元侃 on 15/3/9.
//
//

#import "ChooseContactsViewController.h"
#import "ChooseContactsViewCell.h"
#import "SearchBarCell.h"
#import "AddressBookApi.h"
#import "AddressBookModel.h"
#import "ChatMessageApi.h"
#import "ChooseContactsSearchController.h"
#import "ChatViewController.h"
@interface ChooseContactsViewController()<ChooseContactsViewCellDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)NSMutableArray *groupArr;
@property (nonatomic, strong)NSMutableArray* selectedUserIds;
@property(nonatomic,strong)ChooseContactsSearchController* searchBarTableViewController;
@end

@implementation ChooseContactsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavi];
    [self firstNetWork];
    [self setUpSearchBarWithNeedTableView:YES isTableViewHeader:NO];
    [self initTableView];
}

-(void)initTableView{
    [super initTableView];
}

-(void)firstNetWork{
    [AddressBookApi GetAddressBookListWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            self.groupArr = posts;
            [self.tableView reloadData];
        }
    }keywords:@"" noNetWork:nil];
}

-(void)initNavi{
    self.title=@"选择联系人";
    [self setLeftBtnWithText:@"取消"];
    [self setRightBtnWithText:@"确定"];
}

-(void)rightBtnClicked{
    if(self.selectedUserIds.count == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请先选择联系人" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alertView show];
    }else if(self.selectedUserIds.count ==1){
        ChatViewController* vc=[[ChatViewController alloc]init];
        vc.contactId=self.selectedUserIds[0];
        vc.type=@"01";
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"群聊名称" message:nil delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        UITextField *tf=[alertView textFieldAtIndex:0];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:tf.text forKey:@"name"];
        __block NSString* userIds=@"";
        [self.selectedUserIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            userIds=[userIds stringByAppendingString:obj];
            if (idx==self.selectedUserIds.count-1) return;
            userIds=[userIds stringByAppendingString:@","];
        }];
        [dic setObject:userIds forKey:@"user"];
        [ChatMessageApi CreateWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                [self gotoDetailWithGroupId:posts[0]];
            }
        } dic:dic noNetWork:nil];
    }
}
/*
 @property(nonatomic,strong)NSString *contactId;
 @property(nonatomic,strong)NSString *type;
 */
-(void)gotoDetailWithGroupId:(NSString*)groupId{
    ChatViewController* vc=[[ChatViewController alloc]init];
    vc.contactId=groupId;
    vc.type=@"02";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)sectionDidSelectWithBtn:(UIButton*)btn{
    NSInteger section=btn.tag;
    [self sectionViewClickedWithSection:section];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 47;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.groupArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    AddressBookModel *model = self.groupArr[section];
    return [self sectionSelectedArrayContainsSection:section]?0:model.contactArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    AddressBookModel *model = self.groupArr[section];
    BOOL isShow=![self sectionSelectedArrayContainsSection:section];
    CGFloat sectionHeight=30;
    UIButton* view=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, sectionHeight)];
    view.backgroundColor=[UIColor whiteColor];
    
    NSString* text=model.a_name;
    UIFont* textFont=[UIFont systemFontOfSize:14];
    CGFloat labelWidth=[text boundingRectWithSize:CGSizeMake(9999, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont} context:nil].size.width;
    UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(11, 0, labelWidth, sectionHeight)];
    label.text=text;
    label.textColor=GrayColor;
    label.font=[UIFont systemFontOfSize:14];
    [view addSubview:label];
    
    CGFloat imageViewOrginX=CGRectGetWidth(label.frame)+CGRectGetMinX(label.frame)+5;
    UIImageView* imageView=[[UIImageView alloc]initWithFrame:CGRectMake(imageViewOrginX, 11, 8, 8)];
    imageView.image=[GetImagePath getImagePath:isShow?@"分组打开":@"分组关闭"];
    [view addSubview:imageView];
    
    CGFloat numberLabelWidth=100;
    UILabel* numberLabel=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth-13-numberLabelWidth, 0, numberLabelWidth, sectionHeight)];
    numberLabel.text=model.a_count;
    numberLabel.textAlignment=NSTextAlignmentRight;
    numberLabel.textColor=isShow?[UIColor redColor]:GrayColor;
    numberLabel.font=[UIFont systemFontOfSize:13];
    [view addSubview:numberLabel];
    
    UIView* seperatorLine0=[ChooseContactsViewCell fullSeperatorLine];
    seperatorLine0.center=CGPointMake(view.center.x, 0);
    [view addSubview:seperatorLine0];
    UIView* seperatorLine1=[ChooseContactsViewCell fullSeperatorLine];
    seperatorLine1.center=CGPointMake(view.center.x, CGRectGetHeight(view.frame));
    [view addSubview:seperatorLine1];
    
    [view addTarget:self action:@selector(sectionDidSelectWithBtn:) forControlEvents:UIControlEventTouchUpInside];
    view.tag=section;
    return view;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChooseContactsViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell=[[ChooseContactsViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" delegate:self];
    }
    ChooseContactsCellModel* model=[[ChooseContactsCellModel alloc]init];
    AddressBookModel *ABmodel = self.groupArr[indexPath.section];
    AddressBookContactModel *contactModel = ABmodel.contactArr[indexPath.row];
    model.mainLabelText=contactModel.a_loginName;
    model.isHighlight=[self.selectedUserIds containsObject:contactModel.a_contactId];
    [cell setModel:model indexPath:indexPath];
    
    return cell;
}

-(void)chooseAssistBtn:(UIButton *)btn indexPath:(NSIndexPath *)indexPath{
    AddressBookModel *ABmodel = self.groupArr[indexPath.section];
    AddressBookContactModel *contactModel = ABmodel.contactArr[indexPath.row];
    NSString* userId=contactModel.a_contactId;
    BOOL hasUserId=[self.selectedUserIds containsObject:userId];
    if (hasUserId) {
        [self.selectedUserIds removeObject:userId];
    }else{
        [self.selectedUserIds addObject:userId];
    }
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [super searchBarSearchButtonClicked:searchBar];
    [self.searchBarTableViewController loadListWithKeyWords:searchBar.text];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [super searchBarCancelButtonClicked:searchBar];
    [self firstNetWork];
}

-(void)setUpSearchBarTableView{
    self.searchBarTableViewController=[[ChooseContactsSearchController alloc]initWithTableViewBounds:CGRectMake(0, 0, kScreenWidth, kScreenHeight-CGRectGetMinY(self.searchBar.frame))];
    self.searchBarTableViewController.selectedUserIds=self.selectedUserIds;
    self.searchBarTableViewController.delegate=self;
}

-(NSMutableArray *)selectedUserIds{
    if (!_selectedUserIds) {
        _selectedUserIds=[NSMutableArray array];
    }
    return _selectedUserIds;
}
@end
