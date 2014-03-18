//
//  CDVAlipay.m
//  CordovaLib
//
//  Created by romejiang on 14-3-16.
//
//

#import "CDVAlipay.h"
#import <Foundation/Foundation.h>

#import "PartnerConfig.h"
#import "DataSigner.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import "AlixPayOrder.h"


@implementation CDVAlipay


@synthesize result = _result;

- (void) alipay:(CDVInvokedUrlCommand*)command {
    NSInfo(@"alipay 插件运行开始");
    _result = @selector(paymentResult:);
    
    // 插件初始化和参数处理
    
    CDVPluginResult *pluginResult = nil;
    
    if ([command.arguments count] < 4) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"缺少参数"];
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        //        NSInfo(@"alipay 插件运行开始111");
        return;
    }
    
    NSString* title = [command.arguments objectAtIndex:0];
    NSString* body = [command.arguments objectAtIndex:1];
    NSString* price = [command.arguments objectAtIndex:2];
    NSString* orderno = [command.arguments objectAtIndex:3];
    
    if ([title isEqual:[NSNull null]]){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"标题不能为空"];
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        return;
    }
    if ([body isEqual:[NSNull null]]){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"产品介绍不能为空"];
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        return;
    }
    if ([price isEqual:[NSNull null]]){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"价格不能为空"];
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        return;
    }
    
    
    
    if ([orderno isEqual:[NSNull null]]){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"订单编号不能为空"];
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        return;
    }
    
    //    NSString *nulls = [ NSNull null];
    //    NSInfo(@"alipay arguments = %@ %@ %@ %@ %@", title , body , price , orderno , nulls);
    
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    if (![format numberFromString:price]){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"价格必须是数字"];
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        //        NSInfo(@"alipay 插件运行开始222");
        return ;
    }
    
    
    // 开始调用
    // Check command.arguments here.
    [self.commandDelegate runInBackground:^{
        //        NSString* payload = nil;
        NSInfo(@"alipay 插件运行开始333");
        
        //        初始化订单
        
        
        NSString *appScheme = @"yingyou";
        NSString* orderInfo = [self getOrderInfo:title body:body price:price orderno:orderno];
        //         签名
        NSString* signedStr = [self doRsa:orderInfo];
        
        NSLog(@"signedStr = %@",signedStr);
        
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                                 orderInfo, signedStr, @"RSA"];
        
        //         调用支付接口
        [AlixLibService payOrder:orderString AndScheme:appScheme seletor:_result target:self];
        
        
        
        
        
        
        // Some blocking logic...
        //        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        // The sendPluginResult method is thread-safe.
        //        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
    // 处理插件的返回结果
    
    //    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
    //                                     messageAsString:@"成功调用支付接口"];
    //
    //    [self.commandDelegate sendPluginResult:pluginResult
    //                                callbackId:command.callbackId];
    
    NSInfo(@"alipay 插件运行结束");
}


//wap回调函数
-(void)paymentResult:(NSString *)resultd
{
    //结果处理
#if ! __has_feature(objc_arc)
    AlixPayResult* result = [[[AlixPayResult alloc] initWithString:resultd] autorelease];
#else
    AlixPayResult* result = [[AlixPayResult alloc] initWithString:resultd];
#endif
	if (result)
    {
		
		if (result.statusCode == 9000)
        {
			/*
			 *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
			 */
            
            //交易成功
            NSString* key = AlipayPubKey;//签约帐户后获取到的支付宝公钥
			id<DataVerifier> verifier;
            verifier = CreateRSADataVerifier(key);
            
			if ([verifier verifyString:result.resultString withSign:result.signString])
            {
                //验证签名成功，交易结果无篡改
                NSLog(@"验证签名成功 Result = %@",result);
			}
        }
        else
        {
            //交易失败
            NSLog(@"paymentResult 交易失败 = %@",result);
        }
    }
    else
    {
        //失败
        NSLog(@"paymentResult 失败 = %@",result);
    }
    
}

-(NSString*)getOrderInfo:(NSString*)title body:(NSString*)body price:(NSString*)price orderno:(NSString*)orderno
{
    /*
     *点击获取prodcut实例并初始化订单信息
     */
    
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    order.partner = PartnerID;
    order.seller = SellerID;
    
    order.tradeNO = orderno; //订单ID（由商家自行制定）
    order.productName = title; //商品标题
    order.productDescription = body; //商品描述
    order.amount =  price; //商品价格
    //        order.notifyURL =  @"http%3A%2F%2Fwwww.xxx.com"; //回调URL
    
    return [order description];
}

//     - (NSString *)generateTradeNO
//    {
//        const int N = 15;
//
//        NSString *sourceString = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
//        NSMutableString *result = [[NSMutableString alloc] init] ;
//        srand(time(0));
//        for (int i = 0; i < N; i++)
//        {
//            unsigned index = rand() % [sourceString length];
//            NSString *s = [sourceString substringWithRange:NSMakeRange(index, 1)];
//            [result appendString:s];
//        }
//        return result;
//    }

-(NSString*)doRsa:(NSString*)orderInfo
{
    id<DataSigner> signer;
    signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderInfo];
    return signedString;
}

-(void)paymentResultDelegate:(NSString *)result
{
    NSLog(@"Result = %@",result);
}

@end
