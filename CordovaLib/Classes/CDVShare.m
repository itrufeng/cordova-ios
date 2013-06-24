//
//  CDVShare.m
//  CordovaLib
//
//  Created by 张 舰 on 3/19/13.
//
//

#import "CDVShare.h"

#import <NSLog/NSLog.h>

#import "UMSocialControllerService.h"
//#import "UMSocialConfigDelegate.h"
#import "UMSocialData.h"
#import "UMSocialConfig.h"
#import "UMSocialSnsPlatformManager.h"
#import "WXApi.h"


#define UMShareToWechatSession @"wxsession"
#define UMShareToWechatTimeline @"wxtimeline"
#define UMShareToWeixin @"weixinzidingyi"

@interface CDVShare () <UIActionSheetDelegate>

@property (strong, nonatomic) UMSocialControllerService *socialControllerService;
@property (strong, nonatomic) NSArray *arrayPlatForm;
@property (strong, nonatomic) NSString *shareUrl;
@property (strong, nonatomic) NSMutableArray *arrayPlayName;
@property (strong, nonatomic) UIActionSheet * editActionSheet;
@property (strong, nonatomic) NSMutableData *responseData;


@end

@implementation CDVShare

-(void)pluginInitialize
{
    self.arrayPlatForm = [NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToQzone,UMShareToEmail,UMShareToSms, nil];
    self.arrayPlayName = [NSMutableArray arrayWithObjects:@"微信好友",@"微信朋友圈", nil];
    
    for (NSString *snsName in self.arrayPlatForm)
    {
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName];
        [self.arrayPlayName addObject:snsPlatform.displayName];
    }
    
    _editActionSheet = [[UIActionSheet alloc] initWithTitle:@"分享" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (NSString *snsName in self.arrayPlayName)
    {
        [_editActionSheet addButtonWithTitle:snsName];
        
    }
    [_editActionSheet addButtonWithTitle:@"取消"];
    
    _editActionSheet.cancelButtonIndex = _editActionSheet.numberOfButtons - 1;
    
    _editActionSheet.delegate = self;
    
    _responseData = [[NSMutableData alloc] init];
    

}


- (void) registerUmeng:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"注册友盟key开始");
    
    CDVPluginResult *pluginResult = nil;
    
    NSString *key = [command.arguments count] > 0 ? [command.arguments objectAtIndex:0] : nil;
    
    if (!key)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"需要友盟key"];
        
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        
        NSInfo(@"注册友盟key结束");
        
        return ;
    }
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [UMSocialData setAppKey:key];
                   });
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsString:@"注册友盟完成"];
    
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
    
    NSInfo(@"注册友盟key结束");
}

- (void) registerWeixin:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"注册微信key开始");
    
    CDVPluginResult *pluginResult = nil;
    
    NSString *key = [command.arguments count] > 0 ? [command.arguments objectAtIndex:0] : nil;
    
    if (!key)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"需要微信key"];
        
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        
        NSInfo(@"注册微信key结束");
        
        return ;
    }
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [WXApi registerApp:key];
                   });
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsString:@"注册微信完成"];
    
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
    
    NSInfo(@"注册微信key结束");
}

- (void) share:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"准备分享开始");
    
    CDVPluginResult *pluginResult = nil;
    
    // 传入参数
    NSString *shareText = [command.arguments count] > 0 ? [command.arguments objectAtIndex:0] : nil;
    
    NSString *shareImageUrl = [command.arguments count] > 1 ? [command.arguments objectAtIndex:1] : nil;
    
    _shareUrl = [command.arguments count] > 2? [command.arguments objectAtIndex:2] : @"http://www.xayoudao.com";
    
    NSInfo(@"分享文本:%@\n分享图片路径:%@", shareText, shareImageUrl);
    
    if (!shareText &&
        !shareImageUrl)
    {
        NSInfo(@"分享必须至少有文字或者图片路径任意一个参数");
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"分享至少有文字或者图片路径任意一个参数"];
        
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        
        NSInfo(@"准备分享结束");
        
        return ;
    }
    
    // 初始化分享模块
    
    
    UMSocialData *socialData = [UMSocialData defaultData];
    
    socialData.shareText = shareText?shareText:nil;
    
    if (shareImageUrl)
    {
        UMSocialUrlResource *urlresource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage
                                                                                            url:shareImageUrl];
        
        socialData.urlResource = urlresource;
    }
    
    [_editActionSheet showInView:self.viewController.view];
    
    
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsString:@"可以开始分享"];
    
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
    
    NSInfo(@"准备分享结束");
}

/**************************************************************************************/

#pragma mark -
#pragma mark UMSocialConfigDelegate
#pragma mark -

/**************************************************************************************/

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    _socialControllerService = [UMSocialControllerService defaultControllerService];
    
    if(buttonIndex == 0|| buttonIndex == 1)
    {
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi])
        {
            if (_socialControllerService.currentNavigationController != nil)
            {
                [_socialControllerService performSelector:@selector(close)];
            }
            
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            
            WXMediaMessage *message = [WXMediaMessage message];
            
            //分享的是图片
            if (_socialControllerService.socialData.urlResource)
            {
                UMSocialUrlResource *urlresource = _socialControllerService.socialData.urlResource;

                //                [_ydNet downloadFileWithURL:[NSURL URLWithString:urlresource.url]
//                                     finish:^(NSMutableData *data) {
//                                         message.thumbData = data;
//                                         [self _shareUrlAndTextWith:req
//                                                  andWXMediaMessage:message
//                                                     andButttonIndx:buttonIndex];
//                                         
//                                         
//                                     }
//                                      error:^{
//                                          [self _shareUrlAndTextWith:req
//                                                   andWXMediaMessage:message
//                                                      andButttonIndx:buttonIndex];
//                                          
//                                      }];
            }
            else
            {
                [self _shareUrlAndTextWith:req
                         andWXMediaMessage:message
                            andButttonIndx:buttonIndex];
            }
            
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的设备没有安装微信" delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
            [alertView show];
        }
    }
    else
    {
        NSString *snsName = [self.arrayPlatForm objectAtIndex:buttonIndex-2];
        
        UMSocialSnsPlatform *snsPlatForm = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName];
        
        snsPlatForm.snsClickHandler(self.viewController,_socialControllerService,YES);
        
    }
    
}

/**************************************************************************************/

#pragma mark -
#pragma mark share
#pragma mark -

/**************************************************************************************/

-(void)_shareUrlAndTextWith:(SendMessageToWXReq*)req
          andWXMediaMessage:(WXMediaMessage *)message
             andButttonIndx:(NSInteger)buttonIndex
{
    //分享的文字
    if (_socialControllerService.socialData.shareText)
    {
        message.description = _socialControllerService.socialData.shareText;
    }
    
    //分享url
    if (_shareUrl)
    {
        WXWebpageObject *ext = [WXWebpageObject object];
        
        ext.webpageUrl = _shareUrl;
        
        message.mediaObject = ext;
        
    }
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *strTitle = [infoDict objectForKey:@"CFBundleDisplayName"];
    
    message.title = [NSString stringWithFormat:@"来自于[%@]应用",strTitle];
    
    req.message = message;
    
    req.bText = NO;
    
    if (buttonIndex == 0) {
        req.scene = WXSceneSession;
        [_socialControllerService.socialDataService postSNSWithTypes:[NSArray arrayWithObject:UMShareToWechatSession] content:req.text image:nil location:nil urlResource:nil completion:nil];
    }
    if (buttonIndex == 1) {
        req.scene = WXSceneTimeline;
        [_socialControllerService.socialDataService postSNSWithTypes:[NSArray arrayWithObject:UMShareToWechatTimeline] content:req.text image:nil location:nil urlResource:nil completion:nil];
    }
    [WXApi sendReq:req];
}


@end
