//
//  NSString+FileFormat.h
//  __TESTING__
//
//  Created by 张 舰 on 4/8/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (FileFormat)

/*
 根据Format 获取value
 Format:skip,x=10,y=10,width=40,height=16@2x~iphone.png
 eg:
 NSString *x = [file valueForFileKey:@"x"];
 NSLog(@"the x is %d", x.floatValue);
 output:the x is 10
 */
- (NSString *) valueForFileKey:(NSString *)key ;

/*
 获得文件路径
 eg:
 NSString *path = [@"ex.mp3" valueForFileInPath:@"/help/skip/normal"];
 NSLog(@"the path is %@", path);
 output:the path is /help/skip/normal/ex.mp3
 */
- (NSString *) valueForFileInPath:(NSString *)path ;

/*
 根据Format 获取CGRect
 Format:skip,x=10,y=10,width=40,height=16@2x~iphone.png
 eg:
 CGRect r = [file CGRectForFile];
 NSLog(@"the r is %@",NSStringFromCGRect(r));
 output:the r is {{10,10}, {40,16}}
 */
- (CGRect) CGRectForFile ;

@end
