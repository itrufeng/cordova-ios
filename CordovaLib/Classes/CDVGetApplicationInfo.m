//
//  CDVGetApplicationInfo.m
//  CordovaLib
//
//  Created by jing zhao on 5/28/13.
//
//

#import "CDVGetApplicationInfo.h"

#import <NSLog/NSLog.h>

#import <OpenUDID/OpenUDIDD.h>

#import <ApplicationUnity/ASIFormDataRequest.h>

#import "Setting.h"

@interface CDVGetApplicationInfo ()<NSURLConnectionDelegate>
{
    NSString *strUUID;
    NSString *strCuid;
    int getLocationNums;
}

@property (strong,nonatomic)ApplicationInfo *appInfo;
@property (strong, nonatomic) NSMutableData *d;
@property (strong,nonatomic)ASIFormDataRequest *request;

@end

@implementation CDVGetApplicationInfo

- (void)pluginInitialize;
{
    _d = [[NSMutableData alloc] init];
    
    getLocationNums = 0;
}

-(void)getApplicationInfo:(CDVInvokedUrlCommand*)command
{
    getLocationNums = 0;
    
    strCuid = [command.arguments count] > 0?[command.arguments objectAtIndex:0]:  nil;
    
    if (!strCuid)
    {
        NSWarn(@"没有用户ID");
    }
    
    strUUID = [OpenUDIDD value];
    
    _appInfo = [[ApplicationInfo alloc] init];
    
    [_appInfo setDelegate:self];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];
}


/***********************************************************************************/

#pragma mark -
#pragma mark delegate
#pragma mark -

/**************************************************************************************/

-(void)delegateOnApplicationInfo:(NSDictionary*)dictInfo
{
    if (getLocationNums < 1)
    {
        NSMutableDictionary *dicSend = [NSMutableDictionary dictionaryWithCapacity:10];
        
        [dicSend setDictionary:dictInfo];
        
        [dicSend setObject:APP_ID forKey:KCaid];
        
        [dicSend setObject:strCuid forKey:KCuid];
        
        [dicSend setObject:strUUID forKey:KUdid];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [dicSend setObject:@"ipad" forKey:KPlatform];
        }
        else
        {
            [dicSend setObject:@"iphone" forKey:KPlatform];
        }
        
#ifdef DEBUG
        [dicSend setObject:@"1" forKey:KDev];
#else
        [dicSend setObject:@"0" forKey:KDev];
#endif
        
        
        //请求网络
        
        
        NSError *error = nil;
        
        NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:dicSend
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *url = [NSString stringWithFormat:@"%@/cloud/1/push_ios_add",API_DOMAIN];
        
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        
        _request = request;
        
        [request setRequestMethod:@"POST"];
        
        [request setPostValue:jsonString forKey:@"request"];
        
        [request setCompletionBlock:^{
            
            NSLog(@"请求到的数据 %@", [_request responseString]);
        }];
        
        [request setFailedBlock:^{
            NSWarn(@"网络请求失败错误状态码%d", [_request responseStatusCode]);
        }];
        
        [request startAsynchronous];
        
    }
    
    getLocationNums++;
    
}


@end
