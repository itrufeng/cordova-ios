//
//  ApplicationInfo.h
//  ApplicationInfo
//
//  Created by jing zhao on 5/27/13.
//  Copyright (c) 2013 youdao. All rights reserved.
//


#import <Foundation/Foundation.h>

#define KCaid           @"caid"
#define KCuid           @"cuid"
#define KUdid           @"udid"
#define KToken          @"token"
#define KVersions       @"versions"
#define KPlatform       @"platform"
#define KLongitude	    @"longitude"
#define KLatitude       @"latitude"
#define KOperator       @"operator"
#define KDev            @"dev"

@protocol DelegateApplicationInfo <NSObject>

@required

-(void)delegateOnApplicationInfo:(NSDictionary*)dict;

@end


@interface ApplicationInfo : NSObject

-(void)setDelegate:(id<DelegateApplicationInfo>)_delegate;

-(NSString *)getVersion;

-(NSString *)getProvider;

@end
