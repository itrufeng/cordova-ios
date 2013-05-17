//
//  CDVRedirect.h
//  CordovaLib
//
//  Created by 张 舰 on 5/17/13.
//
//

#import "CDVPlugin.h"

@interface CDVRedirect : CDVPlugin

/*
 打电话给某人
 
 参数：
 [0]:电话号 必须
 */
- (void) callNumber:(CDVInvokedUrlCommand*)command ;

@end
