//
//  NSLog.m
//  ECMobile
//
//  Created by 张 舰 on 3/1/13.
//
//

#import "Log.h"

FOUNDATION_EXPORT void NSInfo(NSString *format, ...)
{
    va_list ap;
    NSString *print;
    
    va_start(ap, format);
    
    print = [[NSString alloc] initWithFormat:format
                                   arguments:ap];
    
    va_end(ap);
    
    NSLog(@"[Info]:%@", print);
    
    [print release];
}

FOUNDATION_EXPORT void NSWarn(NSString *format, ...)
{
    va_list ap;
    NSString *print;
    
    va_start(ap, format);
    
    print = [[NSString alloc] initWithFormat:format
                                   arguments:ap];
    
    va_end(ap);
    
    NSLog(@"[Warn:]%@", print);

#ifdef DEBUG
    
    assert(false);
    
#endif
    
    [print release];
}