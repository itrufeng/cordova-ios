//
//  CDVMessages.m
//  CordovaLib
//
//  Created by 张 舰 on 4/28/13.
//
//

#import "CDVMessages.h"

#import "KGStatusBar.h"

@implementation CDVMessages

- (void) showMsg:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"显示信息开始");
    
    CDVPluginResult *pluginResult = nil;
    
    NSString *msg = [command.arguments count] > 0 ? [command.arguments objectAtIndex:0] : nil;
    
    if (!msg)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"缺少信息这个参数"];
        
        NSInfo(@"显示信息结束");
        
        return ;
    }
    
    [KGStatusBar showSuccessWithStatus:msg];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsString:@"显示信息完成"];
    
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
    
    NSInfo(@"显示信息结束");
}

@end
