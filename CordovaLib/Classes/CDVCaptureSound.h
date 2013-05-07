//
//  CDVCaptureSound.h
//  CordovaLib
//
//  Created by jingzhao on 3/27/13.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CDVPlugin.h"

@interface CDVCaptureSound : CDVPlugin <AVAudioRecorderDelegate>
{
    AVAudioSession *avSession;
   
    AVAudioRecorder* avRecorder;
    
    NSString *        callBackIdSend;
//    CDVPluginResult*  resultSend;
}

/**开始录音
 
 参数：
  -[0]:limitTime限制时间 (否)默认值时30s
 */

- (void)audioRecord:(CDVInvokedUrlCommand*)command;


/**停止录音
 
 参数：不需要传入任何参数
*/

-(void)audioStop:(CDVInvokedUrlCommand*)command;

@end
