//
//  CDVGetUUID.h
//  CordovaLib
//
//  Created by jingzhao on 4/18/13.
//
//

#import <Foundation/Foundation.h>
#import "CDVPlugin.h"
#import <OpenUDID/OpenUDIDD.h>
#import <NSLog/NSLog.h>

@interface CDVGetUUID : CDVPlugin

/*! @brief 获取UUID
 * @return 返回UUID
 */

-(void)getUUID:(CDVInvokedUrlCommand*)command;

@end
