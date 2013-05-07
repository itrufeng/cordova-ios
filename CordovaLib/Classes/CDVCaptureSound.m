//
//  CDVCaptureSound.m
//  CordovaLib
//
//  Created by jingzhao on 3/27/13.
//
//


#import <NSLog/NSLog.h>
#import "CDVCaptureSound.h"

#define CDVCaptureSound_limit_time      @"30"

@implementation CDVCaptureSound

/**************************************************************************************/

#pragma mark -
#pragma mark init
#pragma mark -

/**************************************************************************************/

- (id)initWithWebView:(UIWebView*)theWebView
{
    self = (CDVCaptureSound*)[super initWithWebView:theWebView];
    
    if (self)
    {
        avSession = [AVAudioSession sharedInstance];
        
        // 路径
        NSString* docsPath = [NSTemporaryDirectory ()stringByStandardizingPath];
        
        NSError* err = nil;
        
        NSFileManager* fileMgr = [[NSFileManager alloc] init];
        
        // generate unique file name
        NSString* filePath;
        
        int i = 1;
        
        do {
            filePath = [NSString stringWithFormat:@"%@/audio_%03d.wav", docsPath, i++];
            
        } while([fileMgr fileExistsAtPath:filePath]);
        
        NSURL* fileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
        
        NSDictionary            *dictionarySetting  =   [NSDictionary dictionaryWithObjectsAndKeys:
                                                         [NSNumber   numberWithFloat:16000.0f], AVSampleRateKey,
                                                         [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                                         nil];
        
        // create AVAudioPlayer
        avRecorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:dictionarySetting error:&err];
        
        if (err)
        {
            NSWarn(@"Failed to initialize AVAudioRecorder: %@\n",[err localizedDescription]);
        }
        else
        {
            avRecorder.delegate = self;
            
            [avRecorder prepareToRecord];
        }
    }
    
    return self;
}

/**************************************************************************************/

#pragma mark -
#pragma mark 录音公有调用接口
#pragma mark -

/**************************************************************************************/

/*
 录音开始
 */

- (void)audioRecord:(CDVInvokedUrlCommand*)command
{
    
    NSString *limitTime = [command.arguments count]>0 ? [command.arguments objectAtIndex:0]:CDVCaptureSound_limit_time;
    
    callBackIdSend = command.callbackId;
    
    // 判断录音设备是否存在或者占用
    CDVPluginResult* result = nil;
    
    if (NSClassFromString(@"AVAudioRecorder") == nil )
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"没有提供相应的设备"];
    }
    else if (avRecorder.recording)
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"设备正忙avRecorder.recording"];
    }
    else
    {
        callBackIdSend = command.callbackId;
        
         NSError *error = nil;
         
        [avSession setCategory:AVAudioSessionCategoryRecord error:&error];
        
        [avSession setActive:YES error:&error];
        
        //要设定限制时间
        [avRecorder recordForDuration:[limitTime intValue]];
    }
    
    if(result != nil)
    {
        [self _sendPluginResultWithPluginResult:result andcallBackId:command.callbackId];
    }
}

/*
 录音结束
 */

-(void)audioStop:(CDVInvokedUrlCommand*)command
{
    NSInfo(@"录音结束");
    
    callBackIdSend = command.callbackId;
    
    [self _stopAudioCleanUp];
}


/**************************************************************************************/

#pragma mark -
#pragma mark AVAudioRecorderDelegate
#pragma mark -

/**************************************************************************************/

/*
 成功
 */

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)flag
{
    CDVPluginResult* result = nil;
    
    if (flag)
    {
        NSInfo(@"录音成功");
        
        NSString* filePath = [recorder.url path];
        
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:filePath];
        
    }
    else
    {
        NSInfo(@"录音失败");
        
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"recordDelegate_Successfully:(flag) "];
    }
    
    [self _sendPluginResultWithPluginResult:result andcallBackId:callBackIdSend];
}

/*
失败
 */

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder*)recorder error:(NSError*)error
{
    NSInfo(@"录音失败");
    
    CDVPluginResult* result = nil;
    
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:@"recordDelegate_Successfully:(flag) "];
    [self _sendPluginResultWithPluginResult:result andcallBackId:callBackIdSend];
    
}

/**************************************************************************************/

#pragma mark -
#pragma mark 私有  
#pragma mark -

/**************************************************************************************/

-(void)_stopAudioCleanUp
{

    if (avRecorder.recording)
    {
        [avRecorder stop];
    }
    if (avSession)
    {
        [avSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        [avSession setActive:NO error:nil];
    }

}

-(void)_sendPluginResultWithPluginResult:(CDVPluginResult*)pluginResult
                           andcallBackId:(NSString *)callBackIdInput
{
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:callBackIdInput];
}

@end
