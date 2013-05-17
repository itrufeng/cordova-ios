//
//  CDVRedirect.m
//  CordovaLib
//
//  Created by 张 舰 on 5/17/13.
//
//

#import "CDVRedirect.h"

@implementation CDVRedirect

- (void) callNumber:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"打电话开始");
    
    CDVPluginResult *pluginResult = nil;
    
    NSString *number = [command.arguments count] > 0 ? [command.arguments objectAtIndex:0] : nil;
    
    if (!number)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"需要电话号"];
        
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        
        NSInfo(@"打电话结束");
        
        return ;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", number]]];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsString:@"打电话完成"];
    
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
    
    NSInfo(@"打电话结束");
}

@end
