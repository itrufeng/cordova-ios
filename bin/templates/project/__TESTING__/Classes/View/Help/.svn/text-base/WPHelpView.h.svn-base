//
//  WPHelpView.h
//  ECMobile
//
//  Created by 张 舰 on 2/25/13.
//
//

#import <UIKit/UIKit.h>

@protocol WPHelpViewDelegate ;

@interface WPHelpView : UIView

@property (unsafe_unretained, nonatomic) id<WPHelpViewDelegate> delegate;

/**标记帮助是否看过  */

+ (void) markHelped:(BOOL)helped ;

/** 查看帮助是否看过 */
+ (BOOL) helped ;

@end

@interface WPHelpController : UIViewController

@property (strong, nonatomic) UIImage *image;

@end

@protocol WPHelpViewDelegate <NSObject>

@optional

/** 帮助看完了 */
- (void) helpFinished:(WPHelpView *)helpView ;

@end
