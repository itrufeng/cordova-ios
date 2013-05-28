//
//  ApplicationInfo.h
//  ApplicationInfo
//
//  Created by jing zhao on 5/27/13.
//  Copyright (c) 2013 youdao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ApplicationInfoBlock) (NSArray *array);

@interface ApplicationInfo : NSObject

-(void)setBlock:(ApplicationInfoBlock)block;

-(void)getVersion;

-(void)getProvider;

@end
