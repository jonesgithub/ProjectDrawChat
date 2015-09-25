//
//  CDKFAppDelegate.m
//  KeeFit
//
//  Created by lichen on 5/16/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "CDKFAppDelegate.h"

@implementation CDKFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    //设置Navigation bar的title
//    [[UINavigationBar appearance] setTitleTextAttributes:
//     @{ UITextAttributeTextColor: [UIColor whiteColor],
//        UITextAttributeFont: [UIFont boldSystemFontOfSize:20],
//        UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]}];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    
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
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}







@end
