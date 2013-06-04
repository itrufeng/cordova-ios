/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  __TESTING__
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "Setting.h"

#import <Cordova/CDVPlugin.h>

#import <OpenUDID/OpenUDID.h>

#import <ApplicationInfo/ApplicationInfo.h>
#import <CoreLocation/CoreLocation.h>

#import "WPHelpView.h"
#import "UMSocialData.h"
#import "WXApi.h"
#import "ASIFormDataRequest.h"

// log
#import <NSLog/NSLog.h>

#define NewVersionForCurrentRun @"isnewversionforcurrentrun"

@interface AppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) ASIFormDataRequest *request;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation AppDelegate

@synthesize window, viewController;

- (id)init
{
    /** If you need to do any extra app-specific initialization, you can do it here
     *  -jm
     **/
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
    int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
    
#if __has_feature(objc_arc)
    NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
#else
    NSURLCache* sharedCache = [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"] autorelease];
#endif
    
    [NSURLCache setSharedURLCache:sharedCache];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    self = [super init];
    return self;
}

#pragma mark UIApplicationDelegate implementation

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    
#if ! TARGET_IPHONE_SIMULATOR
	
	[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
	 UIRemoteNotificationTypeSound |
	 UIRemoteNotificationTypeAlert];
    
    [_locationManager startUpdatingLocation];
	
#endif
    
    
    NSString *weixinkey = [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    
    NSString *youmengkey = [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"] objectAtIndex:1] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    
    if (youmengkey &&
        ![youmengkey isEqualToString:@""])
    {
        [UMSocialData setAppKey:youmengkey];
        NSInfo(@"本地注册友盟key:%@", youmengkey);
    }
    
    if (weixinkey &&
        ![weixinkey isEqualToString:@""])
    {
        [WXApi registerApp:weixinkey];
        NSInfo(@"本地注册微信key:%@", weixinkey);
    }
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    
#if __has_feature(objc_arc)
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
#else
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
#endif
    self.window.autoresizesSubviews = YES;
    
#if __has_feature(objc_arc)
    self.viewController = [[MainViewController alloc] init];
#else
    self.viewController = [[[MainViewController alloc] init] autorelease];
#endif
    
    
    // Set your app's start page by setting the <content src='foo.html' /> tag in config.xml.
    // If necessary, uncomment the line below to override it.
    // self.viewController.startPage = @"index.html";
    
    // NOTE: To customize the view's frame size (which defaults to full screen), override
    // [self.viewController viewWillAppear:] in your view controller.
    
    [AppDelegate isNewVersionForCurrentRun];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(reachabilityChanged:)
                                                name:kReachabilityChangedNotification
                                              object:nil];
    [self _creatRechablity];
    
    
    return YES;
}

// this happens while we are running ( in the background, or from within our own app )
// only valid if __TESTING__-Info.plist specifies a protocol to handle

/**应用定向
 
 在应用收到通知，通过通知打开预设的页面
 */
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    if (!url) {
        return NO;
    }
    
    // calls into javascript global function 'handleOpenURL'
    NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
    [self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];
    
    // all plugins will get the notification, and their handlers will be called
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    
    return YES;
}

// repost the localnotification using the default NSNotificationCenter so multiple plugins may respond
- (void)           application:(UIApplication*)application
   didReceiveLocalNotification:(UILocalNotification*)notification
{
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);
    
    return supportedInterfaceOrientations;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}



#pragma push

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	
	NSString *stringToken   =   [[[[NSString stringWithFormat:@"%@", deviceToken] stringByReplacingOccurrencesOfString:@"<"
																											withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSInfo(@"本次注册token:%@", stringToken);
    
    //	NSString *UUID;
    //	if ([[[UIDevice currentDevice]systemVersion] floatValue]> 5.0)
    //	{
    //		UUID = [[UIDevice currentDevice].identifierForVendor UUIDString];
    //	}
    //	else
    //	{
    //		UUID = [UIDevice currentDevice].uniqueIdentifier;
    //	}
    
    ApplicationInfo*  appInfo = [[ApplicationInfo alloc] init];
    
    NSMutableDictionary *dicSend = [NSMutableDictionary dictionaryWithCapacity:10];
    
    [dicSend setObject:APP_ID forKey:KCaid];
    
    [dicSend setObject:[OpenUDID value] forKey:KUdid];
    
    [dicSend setObject:stringToken forKey:KToken];
    
    [dicSend setObject:[appInfo getVersion] forKey:KVersions];
    
    [dicSend setObject:[appInfo getProvider] forKey:KOperator];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [dicSend setObject:@"ipad" forKey:KPlatform];
    }
    else
    {
        [dicSend setObject:@"iphone" forKey:KPlatform];
    }
    
#ifdef DEBUG
    [dicSend setObject:@"1" forKey:KDev];
#else
    [dicSend setObject:@"0" forKey:KDev];
#endif
    
    //请求网络
    NSError *error = nil;
    
    NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:dicSend
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://cloud.appmars.com/cloud/1/push_ios_add"]];
    
    _request = request;
    
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:jsonString forKey:@"request"];
    
    [request setCompletionBlock:^{
        
        NSLog(@"请求到的数据 %@", [_request responseString]);
    }];
    
    [request setFailedBlock:^{
        NSWarn(@"网络请求失败错误状态码%d", [_request responseStatusCode]);
    }];
    
    [request startAsynchronous];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error in registration. Error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *url = [userInfo objectForKey:@"uri"];
    
    if (url)
    {
        NSString *pathResource =  [[NSBundle mainBundle]pathForResource:@"www/index.html" ofType:nil];
        
        NSString* urlResultStr = [NSString stringWithFormat:@"%@%@%@",pathResource,@"?",url];
        
        NSURL *urlResultRequest = [NSURL fileURLWithPath:urlResultStr];
        
        [self.viewController.webView loadRequest:[NSURLRequest requestWithURL:urlResultRequest]];
        
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
}


/**应用进入后台
 
 备注：在此出停止应用对网络监听
 */

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //停止监听在后台
    [hostReach stopNotifier];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

/**应用进入前台
 
 备注：在此出开始应用对网络监听
 */

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //开始监听
    [self _creatRechablity];
    
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


#pragma mark 公有

/**检测版本：帮助页面
 
 检测是否存储过版本号，如果存储
 检测当前的版本号与存储的版本号是否相同，以此来判断是否出现重置帮助页面信息
 */

+ (BOOL) isNewVersionForCurrentRun
{
    NSNumber *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSNumber *version = [[NSUserDefaults standardUserDefaults] valueForKey:NewVersionForCurrentRun];
    
    if (!version)
    {
        [AppDelegate setNewVersionForCurrentRun];
        
        return YES;
    }
    
    if (version.floatValue == currentVersion.floatValue)
    {
        return NO;
    }
    else if (version.floatValue < currentVersion.floatValue)
    {
        [AppDelegate setNewVersionForCurrentRun];
        
        return YES;
    }
    else
    {
        NSWarn(@"版本怎么降低了");
    }
    
    return NO;
}

/**修改版本信息：：帮助页面
 
 将NSUserDefaults版本信息修改为现在的版本信息
 将是否出现过帮助信息重置为No
 */

+ (void) setNewVersionForCurrentRun
{
    NSNumber *version = [[NSUserDefaults standardUserDefaults] valueForKey:NewVersionForCurrentRun];
    
    NSNumber *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSInfo(@"发现新版本 原来的版本是:%f,升级后的版本是%f", version.floatValue, currentVersion.floatValue);
    
    [[NSUserDefaults standardUserDefaults] setValue:currentVersion
                                             forKey:NewVersionForCurrentRun];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [WPHelpView markHelped:NO];
}

#pragma mark 私有

/**监听网络接口
 
 开始监听网络接口
 */

-(void)_creatRechablity
{
    hostReach = [CDVReachability reachabilityWithHostName: @"www.apple.com"];
 	[hostReach startNotifier];
}

#pragma mark 监听事件

/**网络接口错误
 
 可能原因 ：你打开了飞行模式
 你所在的地区网络信号不好
 */
- (void) reachabilityChanged: (NSNotification* )note
{
	CDVReachability* curReach = [note object];
    
    if ([curReach currentReachabilityStatus] == NotReachable )
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"网络错误" message:@"可能原因\n1.你打开了飞行模式\n2.你所在的地区网络信号不好" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        ((UILabel*)[[alertView subviews]objectAtIndex:1]).textAlignment = NSTextAlignmentLeft;
        
        [alertView show];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    
    CLLocation *location = [locations objectAtIndex:0];
    
    NSMutableDictionary *dicSend = [NSMutableDictionary dictionaryWithCapacity:10];
    
    [dicSend setObject:APP_ID forKey:KCaid];
    
    [dicSend setObject:[OpenUDID value] forKey:KUdid];
    
    [dicSend setObject:@"iphone" forKey:KPlatform];
    
    [dicSend setObject:[NSString stringWithFormat:@"%f", location.coordinate.latitude] forKey:KLatitude];
    
    [dicSend setObject:[NSString stringWithFormat:@"%f", location.coordinate.longitude] forKey:KLongitude];
    
#ifdef DEBUG
    [dicSend setObject:@"1" forKey:KDev];
#else
    [dicSend setObject:@"0" forKey:KDev];
#endif

    NSError *error = nil;
    
    NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:dicSend
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://cloud.appmars.com/cloud/1/push_ios_add"]];
    
    _request = request;
    
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:jsonString forKey:@"request"];
    
    [request setCompletionBlock:^{
        
        NSLog(@"请求到的数据 %@", [_request responseString]);
    }];
    
    [request setFailedBlock:^{
        NSWarn(@"网络请求失败错误状态码%d", [_request responseStatusCode]);
    }];
    
    [request startAsynchronous];
}


@end
