//
//  CDVFullScreen.m
//  CordovaLib
//
//  Created by jingzhao on 4/18/13.
//
//

#import "CDVFullScreen.h"
#import <NSLog/NSLog.h>

@implementation CDVFullScreen

/***********************************************************************************/

#pragma mark -
#pragma mark 公有
#pragma mark -

/**************************************************************************************/

/*
全屏
 */

-(void)screenFull:(CDVInvokedUrlCommand*)command
{
     NSInfo(@"全屏开始");
    
    [[UIApplication sharedApplication]setStatusBarHidden:YES
                                           withAnimation:NO];
    
    //调节 origin、高度位置
    [self.viewController.view  setFrame:[UIScreen mainScreen].bounds];
    
    [self.webView setFrame:[UIScreen mainScreen].bounds];

    [self _sendSucessWithParamString:@"全屏成功"
                   commandCallBackID:command.callbackId];
    
    NSInfo(@"全屏结束");
}

/*
 非全屏
 */
-(void)screenNotFull:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"非全屏开始");
    
   [[UIApplication sharedApplication]setStatusBarHidden:NO
                                           withAnimation:NO];
    //调节 origin、高度位置
    CGRect rectNotFullScreen = [UIScreen mainScreen].bounds;
    
    rectNotFullScreen.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    rectNotFullScreen.size.height = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    
    [self.viewController.view  setFrame:rectNotFullScreen];
    
    [self.webView setFrame:CGRectMake(0, 0, rectNotFullScreen.size.width, rectNotFullScreen.size.height)];
    
   [self _sendSucessWithParamString:@"非全屏成功"
                  commandCallBackID:command.callbackId];
    
    NSInfo(@"非全屏结束");
}

/*
 是否全屏
 */
-(void)whetherIsFullScreen:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"是否全屏开始");
    
    BOOL statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    
    NSString *strStatusBarHidden = [NSString stringWithFormat:@"%i",statusBarHidden];
    
    [self _sendSucessWithParamString:strStatusBarHidden
                   commandCallBackID:command.callbackId];
  
    NSInfo(@"是否全屏结束");
}


/***********************************************************************************/

#pragma mark -
#pragma mark 私有
#pragma mark -

/**************************************************************************************/

/*
 方法成功后向外传入参数
 */

-(void)_sendSucessWithParamString:(NSString*)_paramString
               commandCallBackID:(NSString*)_paramCallBackId
{
      CDVPluginResult *pluginResult  = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                       messageAsString:_paramString];
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:_paramCallBackId];

}

@end

