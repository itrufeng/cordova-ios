//
//  CDVUpdate.m
//  CordovaLib
//
//  Created by jingzhao on 4/8/13.
//
//

#import "CDVCheckVersion.h"
#import <NSLog/NSLog.h>
#import <QuartzCore/QuartzCore.h>
#import <ApplicationUnity/ASIHTTPRequest.h>
#import <ApplicationUnity/MobClick.h>

#define CustomActivity_IndicatorViewFrame  CGRectMake(110, 120, 100, 100)
#define CustomActivity_ActivityIndicatorFrame CGRectMake(31, 32, 37, 37)

#define KCDVUpdateVersion_TrackViewUrl      @"trackViewUrl"
#define KCDVUpdateVersion_Result            @"results"
#define KCDVUpdateVersion_Version           @"version"

typedef void (^NewVersion)(BOOL version);


@interface CDVCheckVersion ()<SKStoreProductViewControllerDelegate,
UIAlertViewDelegate,MobClickDelegate>
{
    NSString*   _trackViewUrl;
}

@property (strong, nonatomic) UIView *viewActivityIndicatorView;
@property (strong, nonatomic) UIActivityIndicatorView *largeActivity;
@property (strong, nonatomic) ASIHTTPRequest *asiHttpRequest;


@end

@implementation CDVCheckVersion

/**************************************************************************************/

#pragma mark -
#pragma mark 公有
#pragma mark -

/**************************************************************************************/


-(void)pluginInitialize
{
    //自定制缓冲等待
    self.viewActivityIndicatorView  = [[UIView alloc]initWithFrame:CustomActivity_IndicatorViewFrame];
    [self.viewActivityIndicatorView setBackgroundColor:[UIColor blackColor]];
    [self.viewActivityIndicatorView setAlpha:0.5];
    self.viewActivityIndicatorView.layer.cornerRadius = 10;
    [self.viewController.view addSubview:self.viewActivityIndicatorView];
    self.largeActivity = [[UIActivityIndicatorView alloc]initWithFrame:CustomActivity_ActivityIndicatorFrame];
    self.largeActivity.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhiteLarge;
    [self.viewActivityIndicatorView addSubview:self.largeActivity];
    self.viewActivityIndicatorView.hidden = YES;
    
}
-(void)checkVersion:(CDVInvokedUrlCommand*)command
{
    
    self.viewActivityIndicatorView.hidden = NO;
    [self.largeActivity startAnimating];
    
    NSInfo(@"检测版本开始");
    
    NSString *itunesItemIdentifier = [command.arguments count] > 0?[command.arguments objectAtIndex:0]:  nil;
    
    NSInfo(@"检测新版本传入参数Id = %@",itunesItemIdentifier);
    
    if (!itunesItemIdentifier)
    {
        [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                         WithResultString:@"缺少参数"
                               callbackId:command.callbackId];
        
        [self _showAlertViewWithTitle:@"版本更新"
                          withMessage:@"连接商店信息错误"
                 withCancelButtonInfo:@"忽略"];
        
        self.viewActivityIndicatorView.hidden = YES;
        [self.largeActivity stopAnimating];
        
        return;
    }
    [MobClick checkUpdate];
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(aa)];
    
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.viewActivityIndicatorView.hidden = YES;
        [self.largeActivity stopAnimating];
    });   
    
}

/**************************************************************************************/

#pragma mark -
#pragma mark 私有
#pragma mark -

/**************************************************************************************/


/*弹出Alert信息*/
-(void)_showAlertViewWithTitle:(NSString*)Title
                   withMessage:(NSString*)message
          withCancelButtonInfo:(NSString*)cancelButtonInfo
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:Title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:cancelButtonInfo
                                             otherButtonTitles:nil];
    [alertView show];
    
    
}



/*失败成功后向外传递信息*/

-(void)_sendResultWithPluginResult:(CDVCommandStatus)plugResult
                  WithResultString:(NSString*)resultStr
                        callbackId:(NSString*)callbackId
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:plugResult
                                                      messageAsString:resultStr];
    
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:callbackId];
}

@end
