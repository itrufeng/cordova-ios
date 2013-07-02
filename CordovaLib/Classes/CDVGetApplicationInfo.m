//
//  CDVGetApplicationInfo.m
//  CordovaLib
//
//  Created by jing zhao on 5/28/13.
//
//

#import "CDVGetApplicationInfo.h"

#import <NSLog/NSLog.h>

#import <OpenUDID/OpenUDID.h>

#import <ApplicationUnity/ASIFormDataRequest.h>

#import "Setting.h"

@interface CDVGetApplicationInfo ()<NSURLConnectionDelegate>
{
    NSString *strUUID;
    NSString *strCuid;
}

@property (strong,nonatomic)ApplicationInfo *appInfo;
@property (strong, nonatomic) NSMutableData *d;
@property (strong,nonatomic)ASIFormDataRequest *request;

@end

@implementation CDVGetApplicationInfo

- (void)pluginInitialize;
{
    _d = [[NSMutableData alloc] init];
}

-(void)getApplicationInfo:(CDVInvokedUrlCommand*)command
{
    
    strCuid = [command.arguments count] > 0?[command.arguments objectAtIndex:0]:  nil;
    
    if (!strCuid)
    {
        NSWarn(@"没有用户ID");
    }
    
    strUUID = [OpenUDID value];
    
    _appInfo = [[ApplicationInfo alloc] init];
    
    [_appInfo setDelegate:self];
    
}


/***********************************************************************************/

#pragma mark -
#pragma mark delegate
#pragma mark -

/**************************************************************************************/

-(void)delegateOnApplicationInfo:(NSDictionary*)dictInfo
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
    
        
    
//    NSString *url = [NSString stringWithFormat:@"%@/cloud/1/push_ios_add",API_DOMAIN];
//    
//    NSMutableURLRequest *urlRequset = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//    
//    NSError *error = nil;
//    
//    NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:dicSend
//                                                        options:NSJSONWritingPrettyPrinted
//                                                          error:&error];
//    
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    
//    NSString *StrJson = [[NSString alloc]initWithFormat:@"request=%@",jsonString];
//    [urlRequset setHTTPMethod:@"POST"];
//    
//    [urlRequset setHTTPBody:[StrJson dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [NSURLConnection connectionWithRequest:urlRequset delegate:self];
    
}

///***********************************************************************************/
//
//#pragma mark -
//#pragma mark NSURLConnectionDelegate
//#pragma mark -
//
///**************************************************************************************/
//
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    [_d appendData:data];
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    NSInfo(@"%@", [[NSString alloc] initWithData:_d encoding:NSUTF8StringEncoding]);
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
//{
//    NSWarn(@"网络失败送服务器需要数据%@",error);
//}

@end
