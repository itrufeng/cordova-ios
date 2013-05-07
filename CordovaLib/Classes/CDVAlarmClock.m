//
//  CDVLocalNotication.m
//  CordovaLib
//
//  Created by  Lead To Asia 2 on 2/26/13.
//
//

#import <EventKit/EventKit.h>
#import "CDVAlarmClock.h"
#import <NSLog/NSLog.h>
#import "CDVSingletonEventStore.h"

#define kCDVAlarmClock_UUID           @"uuid"
#define kCDVAlarmClock_FireDate       @"date"
#define kCDVAlarmClock_TimeZone       @"timezone"
#define kCDVAlarmClock_RepeatInterval @"repeatInterval"
#define kCDVAlarmClock_AlertBody      @"alertBody"
#define kCDVLocalNotication_UUID           @"uuid"

typedef void (^ReminderArray)(NSMutableArray *array);
typedef void (^ReminderBolck)(EKReminder *reminder);

@implementation CDVAlarmClock

/**************************************************************************************/

#pragma mark -
#pragma mark 公有
#pragma mark -

/**************************************************************************************/

/*
 add
*/

- (void)addAlarmClock:(CDVInvokedUrlCommand*)command
{
  	NSInfo(@"增加提醒开始");
	
	//传入参数
	NSString *uuid                          = [command.arguments count] > 0?  [command.arguments objectAtIndex:0]:  nil;
	
	NSString  *notificationAlertInformation = [command.arguments count] > 1 ? [command.arguments objectAtIndex:1] : nil;
	
	NSString  *dateStamp                    = [command.arguments count] > 2 ? [command.arguments objectAtIndex:2] : nil;
	
	NSString  * interval                    = [command.arguments count] > 3 ? [command.arguments objectAtIndex:3] : nil;
	
	NSInfo(@"增加提醒输入参数uuid = %@",uuid);
	
	NSInfo(@"增加提醒输入提醒信息 = %@",notificationAlertInformation);
	
	NSInfo(@"增加提醒输入提醒的时间 = %@",dateStamp);
	
	NSInfo(@"增加提醒的时间间隔 = %@",interval);
    
    if (!(uuid && notificationAlertInformation && dateStamp && interval) )
    {
        NSWarn(@"参数不全");
        
        [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                         WithResultString:@"参数不全请查看info"
                               callbackId:command.callbackId];
        return;
    }
	
	//跟着版本走适当的途径
	if ([[[UIDevice currentDevice]systemVersion] floatValue] <= 5.0)
	{
		//查找是否存在
		UILocalNotification *localSearchNotification = [self _searchWithUUID:uuid];
		
		if (localSearchNotification != nil)
		{
			NSWarn(@"增加提醒已经有这个id了uuid = %@",uuid);
            
            [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                             WithResultString:@"已经有这个id了"
                                   callbackId:command.callbackId];
            return;
 		}
        
        [self _addLocalNotificationWithInformation:notificationAlertInformation
                                     WithTimeStamp:[NSDate dateWithTimeIntervalSince1970:dateStamp.doubleValue]
                                      WithTimeZone:[NSTimeZone systemTimeZone]
                                withRepeatInterval:[self _getNSCalendarUnitWithrepeatInterva:interval]
                                          withUUID:uuid];
        
        [self _sendResultWithPluginResult:CDVCommandStatus_OK
                         WithResultString:@"成功"
                               callbackId:command.callbackId];
	}
	else
	{
		CDVSingletonEventStore  *singletonEventStore = [CDVSingletonEventStore shareObject];
		
		EKEventStore *eventStore = singletonEventStore.eventStore;
		
		//查询是否授权
		[eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error)
		 {
			 
			 if (!granted)
			 {
				 NSWarn(@"ios6增加用户日记本没有授权");
                 
                 [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                                  WithResultString:@"ios6增加用户日记本没有授权"
                                        callbackId:command.callbackId];
                 return ;
			 }
             
             //查找是否存在
             [self _ios6LaterSearchReminderWithUUID:uuid
                                  andReturnReminder:^(EKReminder *reminder)
              {
                  
                  if (reminder != nil)
                  {
                      NSWarn(@"增加提醒已经有这个id了uuid = %@",uuid);
                      
                      [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                                       WithResultString:@"已经有这个id了"
                                             callbackId:command.callbackId];
                      return ;
                  }
                  
                  [self _ios6LaterAddReminderWithInformation:notificationAlertInformation
                                               WithTimeStamp:[NSDate dateWithTimeIntervalSince1970:dateStamp.doubleValue]
                                                WithTimeZone:[NSTimeZone systemTimeZone]
                                          withRepeatInterval:interval
                                                    withUUID:uuid];
                        
                  [self _sendResultWithPluginResult:CDVCommandStatus_OK
                                   WithResultString:@"成功"
                                         callbackId:command.callbackId];
              }];
		 }];
	}
	NSInfo(@"增加提醒成功");
}

/*
 delete
 */

-(void)deleteManyAlarmClock:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"删除开始");
	
	//传入参数
	NSArray *array = [command.arguments count]>0?[command.arguments objectAtIndex:0]:nil;
	
	NSInfo(@"删除输入的array里应该放UUID的集合array = %@ ",array);
    
    if (!array)
    {
        NSWarn(@"参数不全");
        
        [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                         WithResultString:@"参数不全请查看info"
                               callbackId:command.callbackId];
        return;
    }
	
    //跟着版本走适当途径
	if ([[[UIDevice currentDevice]systemVersion] floatValue] <= 5.0)
	{
		for (NSString *inputUUID in array)
		{
			//查找
			UILocalNotification *searchLocalNotification = [self _searchWithUUID:inputUUID];
			
			//判断是否存在
			if (searchLocalNotification == nil)
			{
				NSWarn(@"删除UUID并不存在 UUID = %@ ",[searchLocalNotification.userInfo objectForKey:kCDVLocalNotication_UUID]);

                [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                                 WithResultString:[NSString stringWithFormat:@"删除失败 没有此UUID=  %@",inputUUID] 
                                       callbackId:command.callbackId];
                return;
			}
			
				[[UIApplication sharedApplication]cancelLocalNotification:searchLocalNotification];
				
				NSInfo(@"删除UUID成功 UUID = %@ ",[searchLocalNotification.userInfo objectForKey:kCDVLocalNotication_UUID ]);

                [self _sendResultWithPluginResult:CDVCommandStatus_OK
                                 WithResultString:[NSString stringWithFormat:@"删除成功 uuid = %@",inputUUID]
                                       callbackId:command.callbackId];
		
		}
	}
	else
	{
		CDVSingletonEventStore  *singletonEventStore = [CDVSingletonEventStore shareObject];
		
		EKEventStore *eventStore = singletonEventStore.eventStore;
		
		//查询是否授权
		[eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error)
		 {
            if (!granted)
			 {
				 NSWarn(@"ios6删除 用户没有授权");
                 
                 [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                                  WithResultString:@"ios6删除 用户没有授权"
                                        callbackId:command.callbackId];
                 return ;
			 }
			
				 for (NSString *inputUUID in array)
				 {
					 //查找
					 [self _ios6LaterSearchReminderWithUUID:inputUUID
										  andReturnReminder:^(EKReminder *reminder)
					  {
						  if (reminder == nil)
						  {
							  NSWarn(@"ios6用户日记本没有授权");
                              
                              [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                                               WithResultString:[NSString stringWithFormat:@"删除失败 没有此UUID=  %@",inputUUID] callbackId:command.callbackId];
                              return ;
						  }

							  NSError *error = nil;
							  
							  [eventStore removeReminder:reminder commit:YES error:&error];
							  
							  NSLog(@"%@",error);
							  
							  NSInfo(@"删除UUID成功 UUID = %@",inputUUID);
							  
                              [self _sendResultWithPluginResult:CDVCommandStatus_OK
                                               WithResultString:[NSString stringWithFormat:@"删除UUID成功 UUID = %@",inputUUID]
                                                     callbackId:command.callbackId];

					  }];
				 }
		 }];
	}
	NSInfo(@"删除成功");
}

/*
 modify
*/

-(void)modifyAlarmClock:(CDVInvokedUrlCommand*)command
{
	NSInfo(@"修改开始");
		
	NSString  *modifyUUID = [command.arguments count] > 0 ? [command.arguments objectAtIndex:0] : nil;
	
	NSDictionary *dicModifyInfo = [command.arguments count] > 1 ? [command.arguments objectAtIndex:1] : nil;
	
	NSInfo(@"修改的输入参数UUID = %@",modifyUUID);
	
	NSInfo(@"修改的输入参数这里需要的是Dictionary =  %@",dicModifyInfo);
    
    if (!(modifyUUID && dicModifyInfo))
    {
        [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                         WithResultString:@"参数不全请查看info"
                               callbackId:command.callbackId];
        return;
    }
    
	if ([[[UIDevice currentDevice]systemVersion] floatValue] <= 5.0)
	{
	   //查找 UUID
		
		UILocalNotification *searchLocalNortification = [self _searchWithUUID:modifyUUID];
		
		CDVPluginResult *pluginResult = nil;
		
		if (searchLocalNortification  == nil)
		{           
			NSWarn(@"修改UUID并不存在 UUID = ",modifyUUID);
			
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
											 messageAsString:@"本地没有此uuid通知"];
		}
		else
		{
			//获取删除通知的NsDictionary
			NSDictionary *dictSearchLocalNotification = [self _getDictionaryWithlocalNotification:searchLocalNortification];
			
			NSMutableDictionary *mutablDictSearchLocalNotification = [[NSMutableDictionary alloc]initWithDictionary:dictSearchLocalNotification];
			
			//删除通知
			[[UIApplication sharedApplication]cancelLocalNotification:searchLocalNortification];
			
			// 更新旧值
			for (NSString *strKey in [dicModifyInfo allKeys])
			{
				id newValue = [dicModifyInfo objectForKey:strKey];
				
				[mutablDictSearchLocalNotification setValue:newValue
													 forKey:strKey];
			}
			NSString *dateStamp = [mutablDictSearchLocalNotification objectForKey:kCDVAlarmClock_FireDate];
			
			[self _addLocalNotificationWithInformation:[mutablDictSearchLocalNotification objectForKey:kCDVAlarmClock_AlertBody]
										WithTimeStamp:[NSDate dateWithTimeIntervalSince1970:dateStamp.doubleValue]
										 WithTimeZone:[mutablDictSearchLocalNotification objectForKey:kCDVAlarmClock_TimeZone]
								   withRepeatInterval:[self _getNSCalendarUnitWithrepeatInterva:[mutablDictSearchLocalNotification objectForKey:kCDVAlarmClock_RepeatInterval]]
											 withUUID:modifyUUID
			 ];
	
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
															  messageAsString:@"修改成功"];
			 NSInfo(@"修改成功");
		}
		[self.commandDelegate sendPluginResult:pluginResult
									callbackId:command.callbackId];
	}
	else
	{
		CDVSingletonEventStore  *singletonEventStore = [CDVSingletonEventStore shareObject];
		
		EKEventStore *eventStore = singletonEventStore.eventStore;
		
		//是否授权
		[eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error)
		 {
			 CDVPluginResult *pluginResult = nil;
			 
			 if (!granted)
			 {
				 NSWarn(@"修改UUID并不存在 UUID = ",modifyUUID);
				 
				 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
												  messageAsString:@"本地没有此uuid通知"];
				 
				 [self.commandDelegate sendPluginResult:pluginResult
											 callbackId:command.callbackId];
			 }
			 else
			 {
				 [self _ios6LaterSearchReminderWithUUID:modifyUUID
									  andReturnReminder:^(EKReminder *reminder)
				  {
					  CDVPluginResult *pluginResult = nil;
					  
					  if (reminder == nil)
					  {
						  NSWarn(@"修改UUID并不存在 UUID = ",modifyUUID);
						  
						  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
														   messageAsString:@"本地没有此uuid通知"];
					  }
					  else
					  {
						NSDictionary *dicReminder = [self _getDictionaryWithReminder:reminder];
						  
						 NSMutableDictionary *mutablDictReminder = [[NSMutableDictionary alloc]initWithDictionary:dicReminder];
						 
						  CDVSingletonEventStore  *singletonEventStore = [CDVSingletonEventStore shareObject];
						  
						  EKEventStore *eventStore = singletonEventStore.eventStore;
						  
						  NSError *error = nil;
						  
						  //删除通知
						  [eventStore removeReminder:reminder commit:YES error:&error];
						 
						  NSLog(@"%@",error);
						  
						  // 更新旧值
						  for (NSString *strKey in [dicModifyInfo allKeys])
						  {
							  id newValue = [dicModifyInfo objectForKey:strKey];
							  
							  [mutablDictReminder setValue:newValue
													forKey:strKey];
						  }

						 NSString *dateStamp = [mutablDictReminder objectForKey:kCDVAlarmClock_FireDate];
						  
						  [self _ios6LaterAddReminderWithInformation:[mutablDictReminder objectForKey:kCDVAlarmClock_AlertBody]
													   WithTimeStamp:[NSDate dateWithTimeIntervalSince1970:dateStamp.doubleValue]
														WithTimeZone:[NSTimeZone timeZoneWithName:[mutablDictReminder objectForKey:kCDVAlarmClock_TimeZone]]
												  withRepeatInterval:[mutablDictReminder objectForKey:kCDVAlarmClock_RepeatInterval]
															withUUID:[mutablDictReminder objectForKey:kCDVAlarmClock_UUID]];
						
					      NSInfo(@"修改成功");
					  
					      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
																			messageAsString:@"修改成功"];
					  }
						  [self.commandDelegate sendPluginResult:pluginResult
													 callbackId:command.callbackId];
				  }];
			 }
		 }];
	}

   NSInfo(@"修改结束");
}

/*
 search
*/

-(void)searchAlarmClock:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"查找开始");
   	
	//跟着版本走适当途径
	if ([[[UIDevice currentDevice]systemVersion] floatValue] <= 5.0)
	{
		NSArray *arrayLocalNotification = [UIApplication sharedApplication].scheduledLocalNotifications;
		
		NSMutableArray *arrayNewLocalNotification = [[NSMutableArray alloc] initWithCapacity:[arrayLocalNotification count]];
		
		for (UILocalNotification *localNotification in arrayLocalNotification)
		{
			NSDictionary *dicLocalNotication = [self _getDictionaryWithlocalNotification:localNotification];
			
			[arrayNewLocalNotification addObject:dicLocalNotication];
		}
        
		
		CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
														  messageAsArray:arrayNewLocalNotification];
		[self.commandDelegate sendPluginResult:pluginResult
								   callbackId:command.callbackId];
	}
    else
	{
		CDVSingletonEventStore  *singletonEventStore = [CDVSingletonEventStore shareObject];
		
		EKEventStore *eventStore = singletonEventStore.eventStore;
        
		//是否授权
		[eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error)
		 {
			if (!granted)
			 {
				 NSWarn(@"ios6查询 用户没有授权");
                 
                 [self _sendResultWithPluginResult:CDVCommandStatus_ERROR
                                  WithResultString:@"ios6查询 用户没有授权"
                                        callbackId:command.callbackId];
			 }
			 else
			 {
				 [ self _ios6LaterSearchAllReminderArrayContainEkRemider:^(NSMutableArray *arrayReminder)
				 {
					 NSMutableArray *arrayNewReminder = [[NSMutableArray alloc] initWithCapacity:[arrayReminder count]];
					 for (EKReminder *reminder in arrayReminder)
					 {
						 [arrayNewReminder addObject:[self _getDictionaryWithReminder:reminder]];
					 }
				 
					 CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
																		messageAsArray:arrayNewReminder];
					 [self.commandDelegate sendPluginResult:pluginResult
												 callbackId:command.callbackId];
				 }];
			 }
	     }];
	}
	
    NSInfo(@"查找成功");
}

/**************************************************************************************/

#pragma mark -
#pragma mark 私有 ios6以下版本 本地通知
#pragma mark -

/**************************************************************************************/

/*
 add 
*/

-(void)_addLocalNotificationWithInformation:(NSString*)noticationAlertInformation
                              WithTimeStamp:(NSDate*)date
                               WithTimeZone:(NSTimeZone*)timeZone
						 withRepeatInterval:(NSCalendarUnit)repeatInterval
								   withUUID:(NSString*)uuid
{
	UILocalNotification *localNotification = [[UILocalNotification alloc]init];
	
	// 推送内容
    localNotification.alertBody = noticationAlertInformation;
	
    // 设置推送时间
	localNotification.fireDate = date;
	
	localNotification.timeZone = timeZone;
	
	//设置重复时间(如果不设置时间过去了这个通知就没有了)
	localNotification.repeatInterval = repeatInterval;
	
	//声音（现在暂时用系统声音）
	localNotification.soundName =  UILocalNotificationDefaultSoundName;
	
	NSDictionary  *dicUserInfoUUID = @{kCDVLocalNotication_UUID :uuid};
	localNotification.userInfo = dicUserInfoUUID;
	
    [[UIApplication sharedApplication]scheduleLocalNotification:localNotification ];
}

/*
 根据UUID查找 UILocalNotification
*/

-(UILocalNotification*)_searchWithUUID:(NSString*)_searchUUID
{
	UILocalNotification *returnlocalNotification = nil;
	
    NSArray *localNotificationArray = [UIApplication sharedApplication].scheduledLocalNotifications;
	
	for (UILocalNotification *localNotifcation in localNotificationArray)
	{
		NSString *strUUID = [localNotifcation.userInfo objectForKey: kCDVLocalNotication_UUID ];
		
		if ([_searchUUID isEqualToString:strUUID])
		{
			returnlocalNotification = localNotifcation;
			
			break;
		}
	}
	return returnlocalNotification;
}

/*
重新组数据传出去用（将UILocalNotification对象换成NSDictionary ）
*/

-(NSDictionary *)_getDictionaryWithlocalNotification:(UILocalNotification*)localNotification
{
	NSString *UUID = [localNotification.userInfo objectForKey:kCDVLocalNotication_UUID ];
	
	//时间间隔 100是不重复
	int  intRepeatInterval = 100;
	
	if (localNotification.repeatInterval != 0)
	{
		intRepeatInterval = [self _repeatIntervalWithNSCalendarUnit:localNotification.repeatInterval];
	}
	
	NSDictionary *dicLocalNotication = @{kCDVAlarmClock_FireDate:[NSString stringWithFormat:@"%f",[localNotification.fireDate timeIntervalSince1970]],
									  kCDVAlarmClock_TimeZone: localNotification.timeZone.name,
									  kCDVAlarmClock_RepeatInterval: [NSString stringWithFormat:@"%d",intRepeatInterval],
									  kCDVAlarmClock_AlertBody: localNotification.alertBody,
									  kCDVAlarmClock_UUID:UUID
									  };
	return dicLocalNotication;
}

/*
 NSString->NSCalendarUnit
*/

-(NSCalendarUnit)_getNSCalendarUnitWithrepeatInterva:(NSString*)strRepeatInterval
{
	NSCalendarUnit calendarUnit;
	switch ([strRepeatInterval intValue])
	{
		case 0:
			calendarUnit = NSDayCalendarUnit;
			break;
		case 1:
			calendarUnit =NSWeekCalendarUnit;
			break;
		case 2:
			calendarUnit = NSMonthCalendarUnit;
			break;
		case 3:
			calendarUnit = NSYearCalendarUnit;
			break;
		default:
			calendarUnit = 0;
			break;
	}
	return calendarUnit;
}

/*
NSCalendarUnit->int
*/

-(int)_repeatIntervalWithNSCalendarUnit:(NSCalendarUnit)unit
{
	int intRepeatInterval;
	switch (unit)
	{
		case NSDayCalendarUnit:
			intRepeatInterval = 0;
			break;
		case NSWeekCalendarUnit:
			intRepeatInterval = 1;
			break;
		case NSMonthCalendarUnit:
			intRepeatInterval = 2;
	    	break;
		default:
			intRepeatInterval = 3;
			break;
	}
	return intRepeatInterval;
}

/**************************************************************************************/

#pragma mark -
#pragma mark 私有  ios6以上版本 通讯录
#pragma mark -

/**************************************************************************************/

/*
 add 
*/

-(void)_ios6LaterAddReminderWithInformation:(NSString*)reminderTitle
                              WithTimeStamp:(NSDate*)reminderDate
                               WithTimeZone:(NSTimeZone*)reminderTimeZone
						 withRepeatInterval:(NSString*)interVal
								   withUUID:(NSString*)reminderUuid
{
	CDVSingletonEventStore  *singletonEventStore = [CDVSingletonEventStore shareObject];
	
	EKEventStore *eventStore = singletonEventStore.eventStore;
	
	EKReminder *reminder = [EKReminder reminderWithEventStore:eventStore];
	
	reminder.title             =  reminderTitle;
	
	reminder.calendar          = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:eventStore];
	
	reminder.calendar           = [eventStore defaultCalendarForNewReminders];
	
	reminder.dueDateComponents = [self _withInputeDate:reminderDate];
	
	reminder.timeZone          = reminderTimeZone;
	
	if (![interVal isEqualToString:@"100"])
	{
		[reminder addRecurrenceRule:[[EKRecurrenceRule alloc] initRecurrenceWithFrequency:[self _getEKRecurrenceFrequencyWithstrRepeatInterval:interVal]
																				 interval:1
																					  end:nil]];
	}
	
	reminder.notes =  [NSString stringWithFormat:@"uuid=%@",reminderUuid];
	
	NSError *error = nil;
	
	[eventStore saveReminder:reminder commit:YES error:&error];
	
	NSLog(@"localizedFailureReason:%@", error);
}

/*
 在用户已经授权之后调用  用uuid返回符合标准的EKReminder
*/

-(void)_ios6LaterSearchReminderWithUUID:(NSString*)inputUuid
                      andReturnReminder:(ReminderBolck)reminderBlock

{
	//查询所有我们加入的EkRemider
	[self _ios6LaterSearchAllReminderArrayContainEkRemider:^(NSMutableArray *reminderArray)
	{
		EKReminder *reminderSearch;
		
		for (EKReminder *reminder in reminderArray)
		{
			if ([reminder.notes  isEqualToString:[NSString stringWithFormat:@"uuid=%@",inputUuid]])
			{
		        reminderSearch = reminder;
			}
		}
		reminderBlock(reminderSearch);
	}];
}

/*
 在用户已经授权之后调用  查询符合reminder.notes hasPrefix:@"uuid="的记事本事件并返回
 *返回的array里放的是EkRemider
*/

-(void)_ios6LaterSearchAllReminderArrayContainEkRemider:(ReminderArray)reminderArrayBlock
{
	CDVSingletonEventStore  *singletonEventStore = [CDVSingletonEventStore shareObject];
	
	EKEventStore *eventStore = singletonEventStore.eventStore;
	
	NSPredicate *predicate = [eventStore predicateForRemindersInCalendars:nil];
	
	NSMutableArray * mutArrayReminder = [[NSMutableArray alloc]init];
	
	[eventStore fetchRemindersMatchingPredicate:predicate
									 completion:^(NSArray *reminders){
										 
										 for (EKReminder *reminder in reminders)
										 {
											 if ([reminder.notes hasPrefix:@"uuid="])
											 {
												 [mutArrayReminder addObject:reminder];
											 }
										 }
										 reminderArrayBlock(mutArrayReminder);
									 }];
}

/*
 重新组数据传出去用（将EKReminder对象换成NSDictionary ）
*/

-(NSDictionary *)_getDictionaryWithReminder:(EKReminder*)reminder
{
	//时间
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDate *dateReminder  = [gregorian dateFromComponents:reminder.dueDateComponents];
	
	//时间间隔 100是永不重复
	int   interVal =100;
	
	if ([reminder.recurrenceRules count]>0)
	{
		EKRecurrenceRule *reminderRecurrenceRule = [reminder.recurrenceRules objectAtIndex:0];
		
		interVal = reminderRecurrenceRule.frequency;
	}
	
    NSDictionary *dicReminder = @{ kCDVAlarmClock_FireDate: [NSString stringWithFormat:@"%1.0f",[dateReminder timeIntervalSince1970]]
								  ,kCDVAlarmClock_TimeZone: reminder.timeZone.name
								  ,kCDVAlarmClock_RepeatInterval:[NSString stringWithFormat:@"%d",interVal]
								  ,kCDVAlarmClock_AlertBody: reminder.title
								  ,kCDVAlarmClock_UUID: [reminder.notes substringFromIndex:5]
								  };
	return dicReminder;
}

/*
 date转换成NSDateComponents
*/

-(NSDateComponents *)_withInputeDate:(NSDate*)inputDate
{
	NSCalendar *gregorian      = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
	
	unsigned unitFlags         = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	
	NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:inputDate];
	
	return dateComponents;
}

/*
 NSString ->EKRecurrenceFrequency
*/

-(EKRecurrenceFrequency)_getEKRecurrenceFrequencyWithstrRepeatInterval:(NSString*)strRepeatInterval
{
	EKRecurrenceFrequency  recurrenceFrenqucy;
	
	switch ([strRepeatInterval intValue])
	{
		case 0:
			recurrenceFrenqucy = EKRecurrenceFrequencyDaily;
			break;
		case 1:
			recurrenceFrenqucy = EKRecurrenceFrequencyWeekly;
			break;
		case 2:
			recurrenceFrenqucy = EKRecurrenceFrequencyMonthly;
			break;
		default:
			recurrenceFrenqucy = EKRecurrenceFrequencyYearly;
			break;
	}
	return recurrenceFrenqucy;
}

/*失败成功后向外传递信息*/

-(void)_sendResultWithPluginResult:(CDVCommandStatus)plugResult
                  WithResultString:(NSString*)resultStr
                        callbackId:(NSString*)callbackId
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:plugResult
                                                      messageAsString:resultStr];
   
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:callbackId];
}


@end

