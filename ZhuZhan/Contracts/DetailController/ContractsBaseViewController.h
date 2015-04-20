//
//  ContractsBaseViewController.h
//  ZhuZhan
//
//  Created by 孙元侃 on 15/3/30.
//
//

#import "ChatBaseViewController.h"
#import "ContractsListSingleModel.h"
@class RKContractsStagesView;
@class ContractsTradeCodeView;
@interface ContractsBaseViewController : ChatBaseViewController<UIAlertViewDelegate>
@property (nonatomic, strong)UIView* stagesView;
@property (nonatomic, strong)ContractsTradeCodeView* tradeCodeView;
@property (nonatomic, strong)ContractsListSingleModel* listSingleModel;
-(void)sucessPost;
@end
