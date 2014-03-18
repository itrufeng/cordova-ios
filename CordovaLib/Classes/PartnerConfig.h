//
//  PartnerConfig.h
//  AlipaySdkDemo
//
//  Created by ChaoGanYing on 13-5-3.
//  Copyright (c) 2013年 RenFei. All rights reserved.
//
//  提示：如何获取安全校验码和合作身份者id
//  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
//  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
//  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
//

#ifndef MQPDemo_PartnerConfig_h
#define MQPDemo_PartnerConfig_h

//合作身份者id，以2088开头的16位纯数字
#define PartnerID @"2088901482215543"
//收款支付宝账号
#define SellerID  @"yjp-huitian@163.com"

//安全校验码（MD5）密钥，以数字和字母组成的32位字符
#define MD5_KEY @""

//商户私钥，自助生成
#define PartnerPrivKey @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMT+0cEFVkVV+rV5gKCRgOC688gPZp4PIYDd2r16V3k7IihS4EV/nhR7rO1szqmrBP8beUd1BH3Ic3yIMzIWUblhlmLlgAz479YAeUVpWz8P7baKRf1KCS6ENMhrehj0KvSpr/Zpz3apKKE17etl3jubkvApXMIVuMo5fDQBoYEnAgMBAAECgYB66a+Aas8QRfw+3MfH5+Fs1tkie5GAj1pNKJ/B16Lajm3akRND6cN9bklQfrJXpNBiSAcc8cNSpA6CpgyjdM+Z7i60AlttCSAPAfNaQpN4x/5y0L/7NKW3yxCAZOV9h3JxCeYDbXu8J1AdaSbWoXFfgKANAYha4kyLrbg4aEyxAQJBAOHwSEpzxiZf4qTohMHYDFXonvF3zkoCIY5ifipFU42d2eWIzaJ3J8cPG7/up6NtaYzgyEhRNlh7poGG4YbatacCQQDfNLL+RMT04DKNM/uCm7ZToJFZy1XXxdAfIgi150gaN26klKkUR6BFHv6p1tKq0dP6ukJdIhTKfvgkvf83o0iBAkAu4Qo+2HK+t5pxGQWiqs80bAW+mFsnI/YOcwU2hBfoBF6Xr6DrGsoYFVxuoHgMAsGpx2IHD0K1bUKJEZFtx6d1AkEAxRR4/v2lkjnrKLY/WuE2Kbza2hgpoa1tyC961XJzPYK4VOVWLSvZHW7ymO+vb1h5/SY8tpMDHJDjdT21fWDVAQJAbJr/A63DRVJLuW8DUmGCULCOFxrcJExQuj67nuI/dF/8LwBD/x3Qbgj1/bVB7TjCF7qT6MJ6uiHyo5QrsrxMxg=="


//支付宝公钥
#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"

#endif
