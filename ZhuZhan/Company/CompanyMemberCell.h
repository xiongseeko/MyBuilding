//
//  CompanyMemberCell.h
//  ZhuZhan
//
//  Created by 孙元侃 on 14/10/22.
//
//

#import <UIKit/UIKit.h>
#import "EmployeesModel.h"
@interface CompanyMemberCell : UITableViewCell
@property(nonatomic,strong)UIButton* rightBtn;
-(void)setModel:(EmployeesModel*)model indexPathRow:(NSInteger)indexPathRow;
@end