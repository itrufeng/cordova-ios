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

#import "WXApi.h"


#define UMShareToWechatSession @"wxsession"
#define UMShareToWechatTimeline @"wxtimeline"
#define UMShareToWeixin @"weixinzidingyi"

@interface CDVShare () <UIActionSheetDelegate>

@property (strong, nonatomic) UMSocialControllerService *socialControllerService;
@property (strong, nonatomic) NSString *shareUrl;

@end

@implementation CDVShare

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
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
//                       [UMSocialControllerService setSocialConfigDelegate:self];
                       
                       UMSocialData *socialData = [[UMSocialData alloc] initWithIdentifier:@"UMSocialData"];
                       
                       socialData.shareText = shareText ? shareText : nil;
                       
                       if (shareImageUrl)
                       {
                           UMSocialUrlResource *urlresource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage
                                                                                                               url:shareImageUrl];
                           socialData.urlResource = urlresource;
                       }
                       
                       UMSocialControllerService *socialControllerService = [[UMSocialControllerService alloc] initWithUMSocialData:socialData];
                       
                       UINavigationController *shareListController = [socialControllerService getSocialShareListController];
                       
                       [self.viewController presentModalViewController:shareListController animated:YES];
                   });
    
    
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

- (NSArray *)shareToPlatforms
{
//    NSArray *shareToArray = @[@[UMShareToWeixin,UMShareToSina,UMShareToTencent,UMShareToQzone],@[UMShareToEmail,UMShareToSms]];
    NSArray *shareToArray = @[@"1",@"2"];
    return shareToArray;
}

//-(UMSocialSnsPlatform *)socialSnsPlatformWithSnsName:(NSString *)snsName
//{
//    UMSocialSnsPlatform *customSnsPlatform = nil;
//    
//    if ([snsName isEqualToString:UMShareToWeixin])
//    {
//        customSnsPlatform = [[UMSocialSnsPlatform alloc] initWithPlatformName:snsName];
//        
//        customSnsPlatform.bigImageName = @"UMSocialSDKResources.bundle/UMS_wechart_icon"; /*指定大图*/
//        customSnsPlatform.smallImageName = @"UMSocialSDKResources.bundle/UMS_wechart_on.png"; /*指定小图*/
//        customSnsPlatform.displayName = @"微信";    /*指定显示名称*/
//        customSnsPlatform.snsClickHandler = ^(UIViewController *presentingController,
//                                              UMSocialControllerService * socialControllerService,
//                                              BOOL isPresentInController){
//            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"分享到微信"
//                                                                     delegate:self
//                                                            cancelButtonTitle:@"取消"
//                                                       destructiveButtonTitle:nil
//                                                            otherButtonTitles:@"分享给好友", @"分享到朋友圈",nil];
//            if (presentingController.tabBarController != nil) {
//                [actionSheet showInView:presentingController.tabBarController.tabBar];
//            }
//            else{
//                [actionSheet showInView:presentingController.view];
//            }
//            
//            _socialControllerService = socialControllerService;
//        };
//    }
//    return customSnsPlatform;
//}

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
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        if (_socialControllerService.currentNavigationController != nil) {
            [_socialControllerService performSelector:@selector(close)];
        }
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        
        //        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        
        WXMediaMessage *message = [WXMediaMessage message];
        
        //分享的是图片
        if (_socialControllerService.socialData.urlResource)
        {
            UMSocialUrlResource *urlresource = _socialControllerService.socialData.urlResource;
            
            NSData *dataImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlresource.url]];
            
            message.thumbData = dataImage;
        }
        
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
        
        //        // 分享的是文字
        //        if (_socialControllerService.socialData.shareText)
        //        {
        //            req.text = _socialControllerService.socialData.shareText;
        //            req.bText = YES;
        //        }
        //
        //        if (_socialControllerService.socialData.urlResource)
        //        {
        //            UMSocialUrlResource *urlresource = _socialControllerService.socialData.urlResource;
        //
        //            switch (urlresource.resourceType)
        //            {
        //                case UMSocialUrlResourceTypeImage:
        //                {
        //                    WXMediaMessage *message = [WXMediaMessage message];
        //                    WXImageObject *ext = [WXImageObject object];
        //
        //
        //                    ext.imageUrl = urlresource.url;
        //
        //                    message.mediaObject = ext;
        //                    req.message = message;
        //                    req.bText = NO;
        //
        //                    break;
        //                }
        //                default:
        //                {
        //                    WXMediaMessage *message = [WXMediaMessage message];
        //                    WXWebpageObject *ext = [WXWebpageObject object];
        //
        //
        //                    ext.webpageUrl = urlresource.url;
        //
        //                    message.mediaObject = ext;
        //                    req.message = message;
        //                    req.bText = NO;
        //
        //                    break;
        //                }
        //            }
        //        }
        //        else if (_socialControllerService.socialData.shareImage)
        //        {
        //            /*下面实现图片分享，只能分享文字或者分享图片，或者分享url，里面带有图片缩略图和描述文字*/
        //            WXMediaMessage * message = [WXMediaMessage message];
        //            WXImageObject *ext = [WXImageObject object];
        //
        //
        //            ext.imageData = UIImagePNGRepresentation(_socialControllerService.socialData.shareImage);
        //
        //            message.mediaObject = ext;
        //            [message setThumbImage:_socialControllerService.socialData.shareImage];
        //            req.message = message;
        //            req.bText = NO;
        //        }
        
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
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的设备没有安装微信" delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alertView show];
    }
}

@end
