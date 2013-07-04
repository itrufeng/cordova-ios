//
//  CheckVersion.m
//  ApplicationUnity
//
//  Created by jing zhao on 7/4/13.
//  Copyright (c) 2013 youdao. All rights reserved.
//

#import "CheckVersion.h"
#import "ASIHTTPRequest.h"
#import <NSLog/NSLog.h>

#define KCDVUpdateVersion_Variables          @"Variables"
#define KCDVUpdateVersion_AppleID           @"data"
#define KCDVUpdateVersion_TrackViewUrl      @"trackViewUrl"
#define KCDVUpdateVersion_Result            @"results"
#define KCDVUpdateVersion_Version           @"version"

typedef void (^NewVersion)(BOOL version);

@interface CheckVersion ()
{
    NSString*   _trackViewUrl;
}

@property (strong, nonatomic) ASIHTTPRequest *asiHttpRequest;

@end

@implementation CheckVersion

/**************************************************************************************/

#pragma mark -
#pragma mark 公有
#pragma mark -

/**************************************************************************************/


-(void)checkVerSionWithAppleId:(NSString *)appleId
{
 
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://115.28.36.217/cloud/1/app_storeId_get?caid=%@",appleId]];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    _asiHttpRequest  = request;
    
    [request setCompletionBlock:^{
        
        NSError *error = nil;
        
        NSData *dataApp = [_asiHttpRequest responseData];
        
        //解析appstore数据
        NSDictionary *dicApp = [NSJSONSerialization JSONObjectWithData:dataApp
                                                               options:kNilOptions
                                                                 error:&error];
        
        
        NSLog(@"%@",dicApp);
        
        NSDictionary *dic = [dicApp objectForKey:KCDVUpdateVersion_Variables];
        NSString *st = [dicApp objectForKey:@"Version"];
        NSString *intuneId = [dic objectForKey:KCDVUpdateVersion_AppleID];
       
        [self _checkVerSion:intuneId];

    }];
    [request setFailedBlock:^{
       
        NSInfo(@"请求appId网络失败");
    }];
   
    [request startAsynchronous];

}

/**************************************************************************************/

#pragma mark -
#pragma mark UIAlertViewDelegate 
#pragma mark -

/**************************************************************************************/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //ios6以下版本用户点击更新，打开AppStore
    if (buttonIndex == 1)
    {
        UIApplication *application = [UIApplication sharedApplication];
        
        [application openURL:[NSURL URLWithString:_trackViewUrl]];
    }
}
/**************************************************************************************/

#pragma mark -
#pragma mark 私有 是否有新版本
#pragma mark -

/**************************************************************************************/

-(void)_checkVerSion:(NSString*)itunesItemIdentifier
{
    [self _boolHaveNewVersionWithItunesIdentifier:itunesItemIdentifier
                                    andNewVersion:^(BOOL version) {
                                        if (version)
                                        {
                                            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"版本更新"
                                                                                               message:@"发现新版本，是否更新"
                                                                                              delegate:self
                                                                                     cancelButtonTitle:@"忽略"
                                                                                     otherButtonTitles:@"更新", nil];
                                            [alertView show];
                                        }
                                    }];
}



-(void)_boolHaveNewVersionWithItunesIdentifier:(NSString*)itunesItemIdentifier
                                andNewVersion:(NewVersion)boolVersion
{
    
    //当前版本号
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
    
    //AppStore版本号
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",itunesItemIdentifier]];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    _asiHttpRequest = request;
    
    [request setCompletionBlock:^{
        
        NSError *error = nil;
        
        NSData *dataApp = [_asiHttpRequest responseData];
        
        //解析appstore数据
        NSDictionary *dicApp = [NSJSONSerialization JSONObjectWithData:dataApp
                                                               options:kNilOptions
                                                                 error:&error];
        if (error)
        {
            NSInfo(@"获取商店信息错误");
            
            boolVersion(NO);
        }
        else
        {
            NSArray *arrayApp = [dicApp objectForKey:KCDVUpdateVersion_Result];
            
            if ([arrayApp count]== 0)
            {
                NSInfo(@"连接商店信息错误");
                
                boolVersion(NO);
            }
            else
            {
                
                NSDictionary *infoAppResult = [arrayApp objectAtIndex:0];
                
                NSString *stringVersion = [infoAppResult objectForKey:KCDVUpdateVersion_Version];
                
                NSInfo(@"currentVersion= %@取得Version%@",currentVersion,stringVersion);
                
                _trackViewUrl = [infoAppResult objectForKey:KCDVUpdateVersion_TrackViewUrl];
                
                NSInfo(@"取得的_trackUrl%@",_trackViewUrl);
                
                //判断是否有新版本
                if (currentVersion.floatValue < stringVersion.floatValue)
                {
                    NSInfo(@"有新版本");
                    
                    boolVersion(YES);
                }
                else
                {
                    NSInfo(@"没有新版本");
                    boolVersion(NO);
                    
                }
            }
        }
        
    }];
    [request setFailedBlock:^{
        
        
        NSInfo(@"网络请求失败,请重试");
        boolVersion(NO);
    }];
    
    [request startAsynchronous];
     
}


@end
