//
//  CDVAlipay.h
//  CordovaLib
//
//  Created by romejiang on 14-3-16.
//
//

#import <Cordova/CDVPlugin.h>
#import "AlixLibService.h"

@interface CDVAlipay : CDVPlugin{
    SEL _result;
}
@property (nonatomic,assign) SEL result;//这里声明为属性方便在于外部传入。
/*
 显示信息
 参数：
 -[0]:信息 必须
 */
- (void) alipay:(CDVInvokedUrlCommand*)command ;

@end
