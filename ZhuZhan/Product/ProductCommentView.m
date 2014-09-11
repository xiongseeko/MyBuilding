//
//  ProductCommentView.m
//  ZhuZhan
//
//  Created by 孙元侃 on 14-9-3.
//
//

#import "ProductCommentView.h"
#import "EGOImageView.h"

@interface ProductCommentView()
@property(nonatomic,strong)EGOImageView* userImageView;
@property(nonatomic,strong)UILabel* userNameLabel;
@property(nonatomic,strong)UILabel* userCommentContent;
@end

@implementation ProductCommentView

-(instancetype)initWithCommentModel:(CommentModel*)commentModel{
    if ([super init]) {
        [self loadSelfWithCommentModel:commentModel];
    }
    return self;
}

-(void)loadSelfWithCommentModel:(CommentModel*)commentModel{
    NSLog(@"111=====%@",commentModel.a_content);
    //获取用户头像
    self.userImageView=[[EGOImageView alloc]initWithPlaceholderImage:[UIImage imageNamed:@"公司认证员工_05a.png"]];
    self.userImageView.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@"%s%@",serverAddress,commentModel.a_imageUrl]];
    self.userImageView.layer.masksToBounds=YES;
    self.userImageView.layer.cornerRadius=5;
    self.userImageView.frame=CGRectMake(15, 20, 50, 50);
    [self addSubview:self.userImageView];
    
    //用户名称label
    self.userNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(80, 15, 150, 20)];
    self.userNameLabel.text=commentModel.a_name;
    self.userNameLabel.font=[UIFont systemFontOfSize:20];
    //self.userNameLabel.backgroundColor=[UIColor redColor];
    [self addSubview:self.userNameLabel];
    
    //用户评论内容label
    CGRect bounds=[commentModel.a_content boundingRectWithSize:CGSizeMake(213, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    self.userCommentContent=[[UILabel alloc]initWithFrame:CGRectMake(80, 40, 213, bounds.size.height)];
    self.userCommentContent.numberOfLines=0;
    self.userCommentContent.font=[UIFont systemFontOfSize:17];
    self.userCommentContent.text=commentModel.a_content;
    self.userCommentContent.textColor=RGBCOLOR(86, 86, 86);
    [self addSubview:self.userCommentContent];
    
    CGFloat height=0;
    if (self.userCommentContent.frame.size.height>=25) {
        height=bounds.size.height+40+20;
    }else{
        height=90;
    }
    
    self.frame=CGRectMake(6, 0, 308, height);
    self.backgroundColor=[UIColor whiteColor];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
@end

