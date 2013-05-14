//
//  CDVMessages.h
//  CordovaLib
//
//  Created by 张 舰 on 4/28/13.
//
//

#import <Cordova/CDVPlugin.h>

@interface CDVMessages : CDVPlugin

/*
 显示信息
 参数：
 -[0]:信息 必须
 */
- (void) showMsg:(CDVInvokedUrlCommand*)command ;

@end
