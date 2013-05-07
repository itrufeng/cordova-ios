//
//  CDVSingletonEventStore.h
//  CordovaLib
//
//  Created by  Lead To Asia 2 on 3/8/13.
//
//

#import <Foundation/Foundation.h>

#import <EventKit/EventKit.h>


@interface CDVSingletonEventStore : NSObject

/**访问提醒
 
   调用单例eventStore用来访问提醒
 */

@property (strong, nonatomic) EKEventStore*  eventStore;

/**初始化提醒
 
   初始化EKEventStore
 */
+(id)shareObject;

@end
