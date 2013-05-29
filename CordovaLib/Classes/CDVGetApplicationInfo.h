//
//  CDVGetApplicationInfo.h
//  CordovaLib
//
//  Created by jing zhao on 5/28/13.
//
//

#import <Foundation/Foundation.h>

#import "CDVPlugin.h"

#import <ApplicationInfo/ApplicationInfo.h>

@interface CDVGetApplicationInfo : CDVPlugin <DelegateApplicationInfo>

-(void)getApplicationInfo:(CDVInvokedUrlCommand*)command;

@end
