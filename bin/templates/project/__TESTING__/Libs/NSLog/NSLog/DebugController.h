//
//  WPDebugController.h
//  ECMobile
//
//  Created by 张 舰 on 2/27/13.
//
//

#import <UIKit/UIKit.h>

@interface DebugController : UIViewController

+ (void) openLog ;

@end

@interface UIViewController (Debug)

- (void) debugStart ;

@end

