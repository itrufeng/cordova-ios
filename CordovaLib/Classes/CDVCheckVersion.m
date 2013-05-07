//
//  CDVUpdate.m
//  CordovaLib
//
//  Created by jingzhao on 4/8/13.
//
//

#import "CDVCheckVersion.h"
#import <NSLog/NSLog.h>

#define KCDVUpdateVersion_TrackViewUrl      @"trackViewUrl"
#define KCDVUpdateVersion_Result            @"results"
#define KCDVUpdateVersion_Version           @"version"


@interface CDVCheckVersion ()<SKStoreProductViewControllerDelegate,
UIAlertViewDelegate>
{
    NSString*   _trackViewUrl;
}

@end

@implementation CDVCheckVersion

/**************************************************************************************/

#pragma mark -
#pragma mark 公有
#pragma mark -

/**************************************************************************************/

-(void)checkVersion:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"检测版本开始");
    
    NSString *itunesItemIdentifier = [command.arguments count] > 0?[command.arguments objectAtIndex:0]:  nil;
    
    NSInfo(@"检测新版本传入参数Id = %@",itunesItemIdentifier);
    
    if (!itunesItemIdentifier)
    {
        [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                         WithResultString:@"缺少参数"
                               callbackId:command.callbackId];
        
        return;
    }
    
    if ([self _boolHaveNewVersionWithItunesIdentifier:itunesItemIdentifier
                                           andCommand:command])
    {
        //跟着系统版本走适当的途径
        if ([[[UIDevice currentDevice]systemVersion] floatValue] < 6.0)
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"版本更新"
                                                               message:@"发现新版本，是否更新"
                                                              delegate:self
                                                     cancelButtonTitle:@"忽略"
                                                     otherButtonTitles:@"更新", nil];
            [alertView show];
                   
            [self _sendResultWithPluginResult:CDVCommandStatus_OK
                             WithResultString:@"ios6以下用户，弹出alert自己决定去不去商店"
                                   callbackId:command.callbackId];
        }
        else
        {
            //直接在应用内部弹出商店
            SKStoreProductViewController *storeProductController = [[SKStoreProductViewController alloc]init];
            
            storeProductController.delegate = self;
            
            NSDictionary *dictProductIndentify = @{SKStoreProductParameterITunesItemIdentifier:itunesItemIdentifier};
            
            [self.viewController presentViewController:storeProductController
                                              animated:YES
                                            completion:nil];
            
            //passing the iTunes item identifie
            [ storeProductController loadProductWithParameters:dictProductIndentify
                                               completionBlock:^(BOOL result, NSError *error)
             {
                 if (error)
                 {
                     NSWarn(@"加载商店信息错误错误信息= %@",error);
                     
                     [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                                      WithResultString:@"加载商店信息错误错误信息"
                                            callbackId:command.callbackId];
                 }
                 else
                 {
                     [self _sendResultWithPluginResult:CDVCommandStatus_OK
                                      WithResultString:@"加载商店信息成功"
                                            callbackId:command.callbackId];
                 }
                 
             }];
        }
    }
}

/**************************************************************************************/

#pragma mark -
#pragma mark SKStoreProductViewControllerDelegate ios6以上版本
#pragma mark -

/**************************************************************************************/

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self.viewController dismissModalViewControllerAnimated:YES];
    
    NSInfo(@"检测版本结束");
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
#pragma mark 私有  是否有新的版本  失败成功后向外传递信息
#pragma mark -

/**************************************************************************************/

/*
 是否有新的版本
 */

-(BOOL)_boolHaveNewVersionWithItunesIdentifier:(NSString*)itunesItemIdentifier
                                    andCommand:(CDVInvokedUrlCommand*)command
{
    BOOL    boolHaveNewVersion =  NO;
    
    //当前版本号
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
    
    //AppStore版本号
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",itunesItemIdentifier]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    NSError *error = nil;
    
    NSData *dataApp = [NSURLConnection sendSynchronousRequest:urlRequest
                                            returningResponse:nil
                                                        error:&error];
    //从AppStore获取数据是否错误
    if (error)
    {
        NSWarn(@"查询appstore版本信息错误错误信息%@",error);
        
        [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                         WithResultString:@"查询appstore版本信息错误"
                               callbackId:command.callbackId];
    }
    else
    {
        //解析appstore数据
        NSDictionary *dicApp = [NSJSONSerialization JSONObjectWithData:dataApp
                                                               options:kNilOptions
                                                                 error:&error];
        if (error)
        {
            NSWarn(@"对来自appStore数据解析错误 %@",error);
            [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                             WithResultString:@"对来自appStore数据解析错误"
                                   callbackId:command.callbackId];
            
        }
        else
        {
            NSArray *arrayApp = [dicApp objectForKey:KCDVUpdateVersion_Result];
            
            NSDictionary *infoAppResult = [arrayApp objectAtIndex:0];
            
            NSString *stringVersion = [infoAppResult objectForKey:KCDVUpdateVersion_Version];
            
            _trackViewUrl = [infoAppResult objectForKey:KCDVUpdateVersion_TrackViewUrl];
            
            //判断是否有新版本
            if (![stringVersion isEqualToString:currentVersion])
            {
                boolHaveNewVersion = YES;
            }
            else
            {
                
                [self _sendResultWithPluginResult:CDVCommandStatus_OK
                                 WithResultString:@"没有要更新的版本"
                                       callbackId:command.callbackId];
            }
        }
    }
    return boolHaveNewVersion;
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
