//
//  AppDelegate.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-5.
//  Copyright (c) 2014年 zpzchina. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
//#import "LoginSqlite.h"
//#import "ProjectSqlite.h"
//#import "ContactSqlite.h"
//#import "CameraSqlite.h"
//#import "ProjectLogSqlite.h"
//#import "RecordSqlite.h"
#import "FaceppAPI.h"
#import "FaceLoginViewController.h"
#import "HomePageViewController.h"

@implementation AppDelegate

+ (AppDelegate *)instance {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    NSString *API_KEY = KAPI_KEY;
    NSString *API_SECRET = KAPI_SECRET;
    
    // initialize
    [FaceppAPI initWithApiKey:API_KEY andApiSecret:API_SECRET andRegion:APIServerRegionCN];
    
    // turn on the debug mode
    [FaceppAPI setDebugMode:TRUE];
    
    
//    [LoginSqlite opensql];
//    [ProjectSqlite opensql];
//    [ContactSqlite opensql];
//    [CameraSqlite opensql];
//    [RecordSqlite opensql];
//    [ProjectLogSqlite opensql];
//    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
//        NSLog(@"第一次启动");
//        LoginViewController *loginview = [[LoginViewController alloc] init];
//        UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:loginview];
//        
//        [self.window setRootViewController:naVC];
//        self.window.backgroundColor = [UIColor whiteColor];
//        [self.window makeKeyAndVisible];
//    }else{
//        NSLog(@"已经不是第一次启动了");
//        NSLog(@"==>%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"UserToken"]);
//        if (![[NSUserDefaults standardUserDefaults]objectForKey:@"UserToken"]) {
//            LoginViewController *loginview = [[LoginViewController alloc] init];
//            UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:loginview];
//            [self.window setRootViewController:naVC];
//            self.window.backgroundColor = [UIColor whiteColor];
//            [self.window makeKeyAndVisible];
//        }else{
//            //            UIViewController * leftViewController = [[HomePageLeftViewController alloc] init];
//            //            UIViewController * centerViewController = [[HomePageCenterViewController alloc] init];
//            //            UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];
//            //            navigationController.navigationBarHidden = YES;
//            //            drawerController = [[MMDrawerController alloc]
//            //                                                     initWithCenterViewController:navigationController
//            //                                                     leftDrawerViewController:leftViewController
//            //                                                     rightDrawerViewController:nil];
//            //            [drawerController setMaximumRightDrawerWidth:320-62];
//            //            [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
//            //            [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
//            //            [self.window setRootViewController:drawerController];
//            //            self.window.backgroundColor = [UIColor whiteColor];
//            //            [self.window makeKeyAndVisible];
//            NSLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"isFaceRegisted"]);
//            if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"isFaceRegisted"] isEqualToString:@"0"]) {
//                
//                
//                LoginViewController *loginview = [[LoginViewController alloc] init];
//                UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:loginview];
//                
//                [self.window setRootViewController:naVC];
//                self.window.backgroundColor = [UIColor whiteColor];
//                [self.window makeKeyAndVisible];
//            }else{
//                FaceLoginViewController *faceVC = [[FaceLoginViewController alloc] init];
//                UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:faceVC];
//                [self.window setRootViewController:naVC];
//                self.window.backgroundColor = [UIColor whiteColor];
//                [self.window makeKeyAndVisible];
//                
//                
//            }
//            
//        }
//    }
//    
//    return YES;
    HomePageViewController *homeVC = [[HomePageViewController alloc] init];
    self.window.rootViewController = homeVC;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end