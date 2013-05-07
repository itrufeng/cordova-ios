//
//  CDVShare.h
//  CordovaLib
//
//  Created by 张 舰 on 3/19/13.
//
//

#import "CDVPlugin.h"

@interface CDVShare : CDVPlugin

/**注册友盟
 
参数：
 -[0]:key 必须
*/
- (void) registerUmeng:(CDVInvokedUrlCommand*)command ;

/**注册微信
 
参数：
 -[0]:key 必须
*/
- (void) registerWeixin:(CDVInvokedUrlCommand*)command ;

/**分享文本
 
 参数：
 -[0]:分享文本
 -[1]:分享图片url
 备注:文本和图片url至少有一个参数
*/
- (void) share:(CDVInvokedUrlCommand*)command ;

@end
