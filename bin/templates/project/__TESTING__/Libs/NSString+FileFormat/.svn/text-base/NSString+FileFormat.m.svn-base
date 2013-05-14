//
//  NSString+FileFormat.m
//  __TESTING__
//
//  Created by 张 舰 on 4/8/13.
//
//

#import "NSString+FileFormat.h"

@implementation NSString (FileFormat)

- (NSString *) valueForFileKey:(NSString *)key
{
    NSArray *keyValues = [self componentsSeparatedByString:@","];
    
    NSString *value = nil;
    
    for (NSString *keyValue in keyValues)
    {
        if ([keyValue hasPrefix:key] &&
            [keyValue rangeOfString:@"="].location != NSNotFound)
        {
            NSArray *keyValueSeparated = [keyValue componentsSeparatedByString:@"="];
            
            value = [keyValueSeparated count] == 2 ? [keyValueSeparated objectAtIndex:1] : nil;
            
            break;
        }
    }
    
    return value;
}

- (NSString *) valueForFileInPath:(NSString *)path
{
    return [path stringByAppendingPathComponent:self];
}

- (CGRect) CGRectForFile
{
    CGRect rect = CGRectZero;
    
    NSString *fileX = [self valueForFileKey:@"x"];
    
    rect.origin.x = fileX ? fileX.floatValue : 0;
    
    NSString *fileY = [self valueForFileKey:@"y"];
    
    rect.origin.y = fileY ? fileY.floatValue : 0;
    
    NSString *fileWidth = [self valueForFileKey:@"width"];
    
    rect.size.width = fileWidth ? fileWidth.floatValue : 0;
    
    NSString *fileHeight = [self valueForFileKey:@"height"];
    
    rect.size.height = fileHeight ? fileHeight.floatValue : 0;
    
    return rect;
}

@end
