//
//  NSBundle+Image.m
//  BundleTestDemo
//
//  Created by 张 舰 on 2/22/13.
//  Copyright (c) 2013 张 舰. All rights reserved.
//

#import "NSBundle+Image.h"

@implementation NSBundle (Image)

- (NSArray *) picturesWithDirectoryName:(NSString *)direcotryName
{
    // 获取图片名
    
    NSArray *pngs = [self URLsForResourcesWithExtension:@"png"
                                                 subdirectory:direcotryName];
    
    NSLog(@"pngs count:%d", pngs.count);
    
    NSMutableSet *notRepetPngs = [[NSMutableSet alloc] init];
    
    for (NSURL *pngUrl in pngs)
    {
        NSString *pngFileName = [pngUrl.pathComponents lastObject];
        
        NSString *removeAt = [[[pngFileName stringByReplacingOccurrencesOfString:@"@2x~ipad"
                                                                     withString:@""]
                              stringByReplacingOccurrencesOfString:@"@2x~iphone"
                              withString:@""]
                              stringByReplacingOccurrencesOfString:@"@2x"
                              withString:@""];
        
        NSString *removeDeivceTyle = [[[removeAt stringByReplacingOccurrencesOfString:@"~ipad"
                                                                          withString:@""]
                                      stringByReplacingOccurrencesOfString:@"~iphone"
                                      withString:@""]
                                      stringByReplacingOccurrencesOfString:@"@2x"
                                      withString:@""];
        
        [notRepetPngs addObject:removeDeivceTyle];
    }
    
    return [notRepetPngs allObjects];
}

- (NSString *) pictureWithDirectoryName:(NSString *)direcotryName
{
    // 获取图片名
    
    NSArray *pngs = [self URLsForResourcesWithExtension:@"png"
                                           subdirectory:direcotryName];
    
    NSLog(@"pngs count:%d", pngs.count);
    
    NSMutableSet *notRepetPngs = [[NSMutableSet alloc] init];
    
    for (NSURL *pngUrl in pngs)
    {
        NSString *pngFileName = [pngUrl.pathComponents lastObject];
        
        NSString *removeAt = [[[pngFileName stringByReplacingOccurrencesOfString:@"@2x~ipad"
                                                                      withString:@""]
                               stringByReplacingOccurrencesOfString:@"@2x~iphone"
                               withString:@""]
                              stringByReplacingOccurrencesOfString:@"@2x"
                              withString:@""];
        
        NSString *removeDeivceTyle = [[[removeAt stringByReplacingOccurrencesOfString:@"~ipad"
                                                                           withString:@""]
                                       stringByReplacingOccurrencesOfString:@"~iphone"
                                       withString:@""]
                                      stringByReplacingOccurrencesOfString:@"@2x"
                                      withString:@""];
        
        [notRepetPngs addObject:removeDeivceTyle];
    }
    
    return [notRepetPngs count] > 0 ? [notRepetPngs anyObject] : nil;
}

@end
