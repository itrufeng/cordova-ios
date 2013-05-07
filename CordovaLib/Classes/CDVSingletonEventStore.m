//
//  CDVSingletonEventStore.m
//  CordovaLib
//
//  Created by  Lead To Asia 2 on 3/8/13.
//
//

#import "CDVSingletonEventStore.h"

static CDVSingletonEventStore * object;

@implementation CDVSingletonEventStore

+(id)shareObject
{
	if (!object)
	{
		object = [[CDVSingletonEventStore alloc]init];
	}
	return object;

}

-(id)init
{
	self = [super init];
	
	if (self)
	{
		self.eventStore =  [[EKEventStore alloc]init];
	}
	return self;
}


@end
