//
//  WPLoadView.m
//  ECMobile
//
//  Created by 张 舰 on 2/25/13.
//
//

#import "WPLoadView.h"

#import <NSLog/NSLog.h>

#import "NSBundle+Image.h"

@interface WPLoadView ()

@property (strong ,nonatomic) IBOutlet UIImageView *loadimage;

@end

@implementation WPLoadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        
    }
    
    return self;
}

- (void) awakeFromNib
{
    // 初始化加载图片
    UIImage *image = nil;
    if ((image = [self _loadimage]))
        _loadimage.image = image;
    else
        NSWarn(@"工程中找不到加载图片");
}

- (void) dealloc
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - 私有 -

/*
 获取第一张load图片
 */
- (UIImage *) _loadimage
{
    if (iPhone5)
    {
        return [UIImage imageNamed:@"Default-568h.png"];
    }
    else
    {
        return [UIImage imageNamed:@"Default.png"];
    }
}

@end
