//
//  CDVGetUUID.m
//  CordovaLib
//
//  Created by jingzhao on 4/18/13.
//
//

#import "CDVGetUUID.h"

@implementation CDVGetUUID

/***********************************************************************************/

#pragma mark -
#pragma mark 公有
#pragma mark -

/**************************************************************************************/

-(void)getUUID:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"获取UUID开始");
    NSString *strUUID = [OpenUDIDD value];
    
    //向外传送
    CDVPluginResult *pluginResult  = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                       messageAsString:strUUID];
        
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
    
    
    NSInfo(@"获取UUID结束");
}
@end
