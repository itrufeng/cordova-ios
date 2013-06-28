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
    
    //友盟更新
    [MobClick checkUpdate];
    [MobClick setDelegate:self];
    
}

/**************************************************************************************/

#pragma mark -
#pragma mark MobClickDelegate
#pragma mark -

/**************************************************************************************/


- (void)appUpdate:(NSDictionary *)appUpdateInfo
{
    
    NSLog(@"appUpdateInfo = %@",appUpdateInfo);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.largeActivity stopAnimating];
        self.viewActivityIndicatorView.hidden = YES;
        NSString *update = [appUpdateInfo objectForKey:@"update"];
        
        
        if ([update isEqualToString:@"YES"])
        {
            _trackViewUrl = [appUpdateInfo objectForKey:@"path"];
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"版本更新"
                                                               message:@"发现新版本，是否更新"
                                                              delegate:self
                                                     cancelButtonTitle:@"忽略"
                                                     otherButtonTitles:@"更新", nil];
            [alertView show];
            
            
            
        }
        else
        {
            [self _showAlertViewWithTitle:@"版本更新"
                              withMessage:@"没有发现新版本"
                     withCancelButtonInfo:@"忽略"];
        }
        
    });
}

/**************************************************************************************/

#pragma mark -
#pragma mark UIAlertViewDelegate ios6以下版本
#pragma mark -

/**************************************************************************************/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //ios6以下版本用户点击更新，打开AppStore
    if (buttonIndex == 1)
    {
        UIApplication *application = [UIApplication sharedApplication];
        
        [application openURL:[NSURL URLWithString:_trackViewUrl]];
    }
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
