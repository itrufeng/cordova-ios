//
//  CDVGetApplicationInfo.m
//  CordovaLib
//
//  Created by jing zhao on 5/28/13.
//
//

#import "CDVGetApplicationInfo.h"

@interface CDVGetApplicationInfo ()

@property (strong,nonatomic)ApplicationInfo *appInfo;

@end

@implementation CDVGetApplicationInfo

-(void)getApplicationInfo:(CDVInvokedUrlCommand*)command
{
    _appInfo = [[ApplicationInfo alloc] init];
    
    [_appInfo setBlock:^(NSArray *array) {
        NSLog(@"%@",array);
    }];

}

@end
