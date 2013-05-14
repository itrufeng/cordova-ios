//
//  CDVFullScreen.h
//  CordovaLib
//
//  Created by jingzhao on 4/18/13.
//
//

#import <Foundation/Foundation.h>
#import "CDVPlugin.h"

@interface CDVFullScreen : CDVPlugin

/*! @brief 全屏
 */

-(void)screenFull:(CDVInvokedUrlCommand*)command;

/*! @brief 非全屏
 */

-(void)screenNotFull:(CDVInvokedUrlCommand*)command;

/*! @brief 是否全屏
  * @return 成功返回@"0"，失败返回@"1"
 */

-(void)whetherIsFullScreen:(CDVInvokedUrlCommand*)command;

@end
