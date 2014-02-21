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
//  MainViewController.h
//  __TESTING__
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "MainViewController.h"

#include <QuartzCore/QuartzCore.h>
#import <NSLog/NSLog.h>
#import <Cordova/CDVSplashScreen.h>
#import <ApplicationUnity/CheckVersion.h>

#import "WPLoadView.h"
#import "WPHelpView.h"
#import "AppDelegate.h"
#import "NSBundle+Image.h"
#import "Setting.h"


@interface MainViewController () <WPHelpViewDelegate>

@property (strong, nonatomic) WPHelpView *helpView;
@property (strong, nonatomic) CheckVersion* checkVersion;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pageDidLoadFinish) name:CDVPageDidLoadFinishNotification object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.
    //Lower screen 20px on ios 7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        CGRect viewBounds = [self.webView bounds];
        viewBounds.origin.y = 20;
        viewBounds.size.height = viewBounds.size.height - 20;
        self.webView.frame = viewBounds;
        NSLog(@"in version = %f",[[[UIDevice currentDevice] systemVersion] floatValue]);
    }
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.


    [super viewWillAppear:animated];
    
    [self _restoreHelpviewFrame2];
    [self _restoreWebviewFrame2];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //跳过icloud 备份
    NSString *settings = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"settings.plist"];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:settings])
    {
        [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:settings]];
    }
    
    
    NSString *umSocialData =[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@".UMSocialData.plist"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:umSocialData])
    {
        
        [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:settings]];
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    _checkVersion = [[CheckVersion alloc]init];
    
    [_checkVersion checkVerSionWithAppleId:APP_ID];
    
    [self _showHelpView];
    
    [self debugStart];

    [self _setup];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    NSLog(@"");
    
    NSInfo(@"");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/* Comment out the block below to over-ride */

/*
- (UIWebView*) newCordovaViewWithFrame:(CGRect)bounds
{
    return[super newCordovaViewWithFrame:bounds];
}
*/

#pragma mark UIWebDelegate implementation

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    // Black base color for background matches the native apps
    theWebView.backgroundColor = [UIColor blackColor];
    
    [super webViewDidFinishLoad:theWebView];
    
    return;
}

- (void)webView:(UIWebView*)webView
didFailLoadWithError:(NSError*)error
{
    [super webView:webView
didFailLoadWithError:error];
    
    NSInfo(@"加载Web数据错误:\n\%@", [error localizedFailureReason]);
}

/* Comment out the block below to over-ride */

/*
 
 - (void) webViewDidStartLoad:(UIWebView*)theWebView
 {
 return [super webViewDidStartLoad:theWebView];
 }
 
 - (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
 {
 return [super webView:theWebView didFailLoadWithError:error];
 }
 
 - (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
 {
 return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
 }
 */

#pragma mark 私有
/* 显示帮助 */
- (void) _showHelpView
{
    // 看过帮助
    if (YES == [WPHelpView helped])
        return ;
    
    // 未启用该插件
    NSArray *imageFils = [[NSBundle mainBundle] picturesWithDirectoryName:@"help"];
    
    if ([imageFils count] == 0)
    {
        NSInfo(@"没有帮助图片");
        return;
    }
    
    NSInfo(@"显示帮助信息开始");
    
    if (nil == _helpView)
    {
        _helpView = [[[NSBundle mainBundle] loadNibNamed:@"WPHelpView"
                                                   owner:nil
                                                 options:nil] lastObject];
        
        _helpView.delegate = self;
        
        [self.view insertSubview:_helpView
                    aboveSubview:self.webView];
        
    }
    
    _helpView.hidden = NO;
}

/* 隐藏帮助 */
- (void) _hiddenHelpView
{
    if (nil == _helpView)
        return;

    // - acimation
    CATransition            *transitionC        =   [CATransition animation];
    
    transitionC.duration                        =   0.5f;
    
    transitionC.timingFunction                  =   [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    transitionC.type                            =   kCATransitionFade;
    
    transitionC.subtype                         =   kCATransitionFromRight;
    
    [_helpView.layer addAnimation:transitionC
                           forKey:nil];
    _helpView.hidden = YES;
    
    NSInfo(@"显示帮助信息结束");
}

#pragma mark WPHelpViewDelegate

/* 帮助看完了 */
- (void) helpFinished:(WPHelpView *)helpView
{
    [self _hiddenHelpView];
    
    [WPHelpView markHelped:YES];
}

/* 修正helpviewFrame */
- (void) _restoreHelpviewFrame
{
    // CGRect frame = _helpView.frame;
    // frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    // frame.size.height =[UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    // _helpView.frame = frame;
}

/* 修正helpviewFrame */
- (void) _restoreHelpviewFrame2
{
    // CGRect frame = _helpView.frame;
    // frame.origin.y = 0;
    // frame.size.height =[UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    // _helpView.frame = frame;
}

/* 修正helpviewFrame */
- (void) _restoreWebviewFrame
{
    // CGRect frame = self.webView.frame;
    // frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    // frame.size.height =[UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    // NSLog(@"webView frame is:%@", NSStringFromCGRect(frame));
    // self.webView.frame = frame;
}

/* 修正helpviewFrame */
- (void) _restoreWebviewFrame2
{
    // CGRect frame = self.webView.frame;
    // frame.origin.y = 0;
    // frame.size.height =[UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    // NSLog(@"webView frame is:%@", NSStringFromCGRect(frame));
    // self.webView.frame = frame;
}

- (void) _setup
{
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
}

#pragma mark - CDVPageDidLoadFinishNotification
- (void) _pageDidLoadFinish
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self _restoreHelpviewFrame2];
    
    [self _restoreWebviewFrame2];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

@end

@implementation MainCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
   in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

/*
   NOTE: this will only inspect execute calls coming explicitly from native plugins,
   not the commandQueue (from JavaScript). To see execute calls from JavaScript, see
   MainCommandQueue below
*/
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

- (NSString*)pathForResource:(NSString*)resourcepath;
{
    return [super pathForResource:resourcepath];
}

@end

@implementation MainCommandQueue

/* To override, uncomment the line in the init function(s)
   in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end
