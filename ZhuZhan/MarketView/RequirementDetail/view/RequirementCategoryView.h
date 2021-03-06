//
//  RequirementCategoryView.h
//  ZhuZhan
//
//  Created by 孙元侃 on 15/6/9.
//
//

#import <UIKit/UIKit.h>

@protocol RequirementCategoryViewDelegate <NSObject>
- (void)requirementCategoryViewAssistBtnClicked;
@end

@interface RequirementCategoryView : UIView
- (void)setTitle:(NSString*)title;
@property (nonatomic, strong)UIButton* assistView;
@property (nonatomic, weak)id<RequirementCategoryViewDelegate> delegate;
@end
