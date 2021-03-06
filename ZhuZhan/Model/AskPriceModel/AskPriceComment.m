//
//  AskPriceComment.m
//  ZhuZhan
//
//  Created by 汪洋 on 15/3/27.
//
//

#import "AskPriceComment.h"
#import "ProjectStage.h"
#import "LoginSqlite.h"
@implementation AskPriceComment
-(void)setDict:(NSDictionary *)dict{
    _dict = dict;
    self.a_id = dict[@"id"];
    self.a_name = dict[@"commentsUserName"];
    self.a_contents = dict[@"contents"];
    self.a_createdBy = dict[@"createdBy"];
    self.a_createdTime = [NSString stringWithFormat:@"%@",[ProjectStage ProjectNewTimeStage:dict[@"createdTime"]]];
    self.a_quoteId = dict[@"quoteId"];
    self.a_tradeCode = dict[@"tradeCode"];
    self.a_tradeId = dict[@"tradeId"];
    self.a_tradeUserAndCommentUser = dict[@"tradeUserAndCommentUser"];
    if([dict[@"createdBy"] isEqualToString:[LoginSqlite getdata:@"userId"]]){
        self.a_isSelf = YES;
    }else{
        self.a_isSelf = NO;
    }
    
    if([dict[@"userType"] isEqualToString:@"01"]){
        self.a_isVerified = @"平台未认证企业资质，请注意交流过程中的风险。";
        self.a_isHonesty = NO;
    }else{
        self.a_isVerified = @"平台认证企业资质，诚实可信";
        self.a_isHonesty = YES;
    }
}
@end
