//
//  UpdataPassWordViewController.m
//  ZpzchinaMobile
//
//  Created by 汪洋 on 14-10-10.
//  Copyright (c) 2014年 汪洋. All rights reserved.
//

#import "UpdataPassWordViewController.h"
#import "AppDelegate.h"
#import "HomePageViewController.h"
#import "LoginSqlite.h"
#import "LoginModel.h"
#import "MD5.h"
#import "RemindView.h"
#import "MBProgressHUD.h"
#import "EndEditingGesture.h"
@interface UpdataPassWordViewController ()

@end

@implementation UpdataPassWordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"修改密码";
    self.view.backgroundColor = RGBCOLOR(245, 246, 248);
    //LeftButton设置属性
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 25, 22)];
    [leftButton setBackgroundImage:[GetImagePath getImagePath:@"013"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIView* topView=[[UIView alloc]initWithFrame:CGRectMake(0, 80, 320, 141)];
    topView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:topView];
    UIImageView* backView=[[UIImageView alloc]initWithImage:[GetImagePath getImagePath:@"注册_04"]];
    [topView addSubview:backView];
    
//    UILabel *oldPassWord = [[UILabel alloc] initWithFrame:CGRectMake(15, 70, 60, 30)];
//    oldPassWord.textColor = BlueColor;
//    oldPassWord.text = @"原密码";
//    oldPassWord.font = [UIFont fontWithName:@"GurmukhiMN" size:14];
//    [self.view addSubview:oldPassWord];
    
    oldPassWordTextField = [[UITextField alloc] initWithFrame:CGRectMake(22,4,276,47)];
    oldPassWordTextField.placeholder = @"原密码";
    oldPassWordTextField.font = [UIFont systemFontOfSize:14];
    oldPassWordTextField.delegate = self;
    oldPassWordTextField.secureTextEntry = YES;
    oldPassWordTextField.clearButtonMode = UITextFieldViewModeAlways;
    //[oldPassWordTextField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [topView addSubview:oldPassWordTextField];
    
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 99, 280, 1)];
    [lineImage setBackgroundColor:[UIColor blackColor]];
    [topView addSubview:lineImage];
    lineImage.alpha = 0.2;
    
//    UILabel *newPassWord = [[UILabel alloc] initWithFrame:CGRectMake(15, 115, 60, 30)];
//    newPassWord.textColor = BlueColor;
//    newPassWord.text = @"新密码";
//    newPassWord.font = [UIFont fontWithName:@"GurmukhiMN" size:14];
//    [self.view addSubview:newPassWord];
    
    newPassWordTextField = [[UITextField alloc] initWithFrame:CGRectMake(22,51,276,47)];
    newPassWordTextField.placeholder = @"新密码6-20位";
    newPassWordTextField.font = [UIFont systemFontOfSize:14];
    newPassWordTextField.delegate = self;
    newPassWordTextField.secureTextEntry = YES;
    newPassWordTextField.clearButtonMode = UITextFieldViewModeAlways;
    //[newPassWordTextField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [topView addSubview:newPassWordTextField];
    
    UIImageView *lineImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 49, 280, 1)];
    [lineImage2 setBackgroundColor:[UIColor blackColor]];
    [topView addSubview:lineImage2];
    lineImage2.alpha = 0.2;
    
//    UILabel *newAgainPassWord = [[UILabel alloc] initWithFrame:CGRectMake(15, 160, 60, 30)];
//    newAgainPassWord.textColor = BlueColor;
//    newAgainPassWord.text = @"重复密码";
//    newAgainPassWord.font = [UIFont fontWithName:@"GurmukhiMN" size:14];
//    [self.view addSubview:newAgainPassWord];
    
    newAgainPassWordTextField = [[UITextField alloc] initWithFrame:CGRectMake(22,100,276,47)];
    newAgainPassWordTextField.placeholder = @"再次输入";
    newAgainPassWordTextField.font = [UIFont systemFontOfSize:14];
    newAgainPassWordTextField.delegate = self;
    newAgainPassWordTextField.secureTextEntry = YES;
    newAgainPassWordTextField.clearButtonMode = UITextFieldViewModeAlways;
    //[newAgainPassWordTextField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [topView addSubview:newAgainPassWordTextField];
    
//    UIImageView *lineImage3 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 158, 280, 1)];
//    [lineImage3 setBackgroundColor:[UIColor blackColor]];
//    [topView addSubview:lineImage3];
//    lineImage3.alpha = 0.2;
    
    confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(22, kScreenHeight-68, 276, 42);
    [confirmBtn setImage:[GetImagePath getImagePath:@"用户条款_05"] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(updataPassWordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    
    [EndEditingGesture addGestureToView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)leftBtnClick{//退出到前一个页面
    [self.navigationController popViewControllerAnimated:YES];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if(textField == newPassWordTextField){
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([toBeString length] > 20) {
            newPassWordTextField.text = [toBeString substringToIndex:20];
            return NO;
        }
        return YES;
    }else if (textField == newAgainPassWordTextField){
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([toBeString length] > 20) {
            newAgainPassWordTextField.text = [toBeString substringToIndex:20];
            return NO;
        }
        return YES;
    }else{
        return YES;
    }
}


-(void)updataPassWordAction{
    if(newPassWordTextField.text.length<6){
        [RemindView remindViewWithContent:@"密码大于6位" superView:self.view centerY:260];
        return;
    }
    
//    NSRange newPassWordTextFieldRange = [newPassWordTextField.text rangeOfString:@" "];
//    if (newPassWordTextFieldRange.location != NSNotFound) {
//        //有空格
//        [RemindView remindViewWithContent:@"密码不能包含空格" superView:self.view centerY:260];
//        return;
//    }
    
    if(![newPassWordTextField.text isEqualToString:newAgainPassWordTextField.text]){
        [RemindView remindViewWithContent:@"密码输入不一致，请重新输入" superView:self.view centerY:260];
    }else{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:[MD5 md5HexDigest:oldPassWordTextField.text] forKey:@"oldPassword"];
        [dic setValue:[MD5 md5HexDigest:newPassWordTextField.text] forKey:@"newPassword"];
        [LoginModel ChangePasswordWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                [self.navigationController popViewControllerAnimated:YES];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"修改成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }else{
                [LoginAgain AddLoginView:NO];
            }
        } dic:dic noNetWork:^{
            [MBProgressHUD myShowHUDAddedTo:self.view animated:YES];
        }];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)LetterNoErr:(NSString *)phone
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:phone options:0 range:NSMakeRange(0, [phone length])];
    if (numberOfMatches ==phone.length) {
        [RemindView remindViewWithContent:@"密码不能为全英文" superView:self.view centerY:260];
        return NO;
    }
    return YES;
}

-(BOOL)NumberNoErr:(NSString *)phone
{
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:phone options:0 range:NSMakeRange(0, [phone length])];
    if (numberOfMatches ==phone.length) {
        [RemindView remindViewWithContent:@"密码不能为全数字" superView:self.view centerY:260];
        return NO;
    }
    return YES;
}

-(BOOL)SymbolNoErr:(NSString *)phone
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[-@_]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:phone options:0 range:NSMakeRange(0, [phone length])];
    if (numberOfMatches ==phone.length) {
        [RemindView remindViewWithContent:@"密码不能为全符号" superView:self.view centerY:260];
        return NO;
    }
    return YES;
}
@end
