//
//  ContactTableViewCell.h
//  ZhuZhan
//
//  Created by 汪洋 on 14-9-3.
//
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface ContactTableViewCell : UITableViewCell{
    EGOImageView *headImageView;
    UIImageView *stageImage;
    UILabel *titleLabel;
    UILabel *nameLabel;
    UILabel *jobLabel;
}

@end
