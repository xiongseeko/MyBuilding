//
//  CompanyModel.m
//  ZhuZhan
//
//  Created by 汪洋 on 14/10/20.
//
//

#import "CompanyModel.h"
#import "ProjectStage.h"
@implementation CompanyModel
-(void)setDict:(NSDictionary *)dict{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _dict = dict;
    self.a_id = [ProjectStage ProjectStrStage:dict[@"companyId"]];
    self.a_companyName = [ProjectStage ProjectStrStage:dict[@"companyName"]];
    self.a_companyIndustry = [ProjectStage ProjectStrStage:dict[@"companyIndustry"]];
    self.a_companyFocusNumber = [ProjectStage ProjectStrStage:[NSString stringWithFormat:@"%@",dict[@"focusNum"]]];
    self.a_companyEmployeeNumber = [ProjectStage ProjectStrStage:[NSString stringWithFormat:@"%@",dict[@"employeesNum"]]];
    self.a_companyDescription = [ProjectStage ProjectStrStage:dict[@"companyDesc"]];
    if(![[ProjectStage ProjectStrStage:dict[@"headImageId"]] isEqualToString:@""]){
        self.a_companyLogo = [NSString stringWithFormat:@"%@%@",[userDefaults objectForKey:@"serverAddress"],image([ProjectStage ProjectStrStage:dict[@"headImageId"]], @"login", @"", @"", @"")];
    }else{
        self.a_companyLogo = [ProjectStage ProjectStrStage:dict[@"loginImagesId"]];
    }
    self.a_focused = [ProjectStage ProjectStrStage:[NSString stringWithFormat:@"%@",dict[@"isFocus"]]];
    self.a_companyContactName = [ProjectStage ProjectStrStage:dict[@"contactName"]];
    self.a_companyContactCellphone = [ProjectStage ProjectStrStage:dict[@"contactTel"]];
    self.a_companyContactEmail = [ProjectStage ProjectStrStage:dict[@"companyEmail"]];
    self.a_companyLocation = [ProjectStage ProjectStrStage:dict[@"address"]];
    self.a_companyProvince = [ProjectStage ProjectStrStage:dict[@"landProvince"]];
    self.a_companyCity = [ProjectStage ProjectStrStage:dict[@"landCity"]];
    self.a_companyDistrict = [ProjectStage ProjectStrStage:dict[@"landDistrict"]];
    self.a_reviewStatus = [ProjectStage ProjectStrStage:dict[@"reviewStatus"]];
    self.a_loginName = [ProjectStage ProjectStrStage:dict[@"loginName"]];
}
@end
