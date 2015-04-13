//
//  ChatMessageApi.h
//  ZhuZhan
//
//  Created by 汪洋 on 15/4/9.
//
//

#import <Foundation/Foundation.h>

@interface ChatMessageApi : NSObject
//创建群
+ (NSURLSessionDataTask *)CreateWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block dic:(NSMutableDictionary *)dic noNetWork:(void(^)())noNetWork;

//获取会话列表
+ (NSURLSessionDataTask *)GetListWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block noNetWork:(void(^)())noNetWork;

//获取聊天记录
+ (NSURLSessionDataTask *)GetMessageListWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block userId:(NSString *)userId startIndex:(int)startIndex noNetWork:(void(^)())noNetWork;

//删除会话
+ (NSURLSessionDataTask *)DelMessageListWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block dic:(NSMutableDictionary *)dic noNetWork:(void(^)())noNetWork;
@end
