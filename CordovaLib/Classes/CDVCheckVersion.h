//
//  CDVUpdate.h
//  CordovaLib
//
//  Created by jingzhao on 4/8/13.
//
//

#import <Foundation/Foundation.h>
#import "CDVPlugin.h"
#import <StoreKit/StoreKit.h>


@interface CDVCheckVersion : CDVPlugin

/**更新版本
 
 参数：不需要传入任何参数
 *备注：此方法一旦调用具体的实现方式由本地操作*
 */
-(void)checkVersion:(CDVInvokedUrlCommand*)command;


@end
