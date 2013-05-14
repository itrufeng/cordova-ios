//
//  CDVLocalNotication.h
//  CordovaLib
//
//  Created by  Lead To Asia 2 on 2/26/13.
//
//

#import <Foundation/Foundation.h>
#import "CDVPlugin.h"

@interface CDVAlarmClock : CDVPlugin

/*
 所有变量名字
  * date              日期
  * timezone          时区
  * repeatInterval   间隔时间
  * alertBody         内容
 

 时间间隔参数：
 *0 是 每天重复
 *1 是 每周重复
 *2 是 每月重复
 *3 是 每年重复
 *100  永不重复
 
 */


/**add
 
 参数：
  -[0]:Id              必须
  -[1]:提醒的内容        必须
  -[2]:日期时间戳        必须
  -[3]:时间间隔          必须
 */

- (void)addAlarmClock:(CDVInvokedUrlCommand*)command ;

/**search

 参数：不需要传入任何参数 
 */

-(void)searchAlarmClock:(CDVInvokedUrlCommand*)command ;

/**delete 
 
 参数：
  -[0]:Id              必须
 */

-(void)deleteManyAlarmClock:(CDVInvokedUrlCommand*)command;

/**modify
 
  参数：
   -[0]:Id              必须
   -[1]:dictmodify      必须         eg:{"date" = "value","timezone" = "value2","repeatInterval" = "value3","alertBody" = "value4"} 里面的参数可选                                                                                                                    
 */

-(void)modifyAlarmClock:(CDVInvokedUrlCommand*)command ;

@end
