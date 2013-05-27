//
//  WPHelpView.m
//  ECMobile
//
//  Created by 张 舰 on 2/25/13.
//
//

#import "WPHelpView.h"

#import <NSLog/NSLog.h>

#import "FireUIPagedScrollView.h"
#import "NSBundle+Image.h"
#import "NSString+FileFormat.h"

#define WPHELPVIEW_MARKHELPED   @"wphelpview_markhelped"

@interface WPHelpView () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet FireUIPagedScrollView *helpPages;
@property (strong, nonatomic) IBOutlet UIButton *skip;

@end

@implementation WPHelpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    
}

- (void) awakeFromNib
{
    // 获得帮助资源包图片名
    NSArray *helpImageNames = [self _helpImageNames];
    
    if (!(helpImageNames = [self _helpImageNames]))
        NSWarn(@"没有找到帮助图片");
    
    for (NSString *imageName in helpImageNames)
    {
        WPHelpController *helpController = [[WPHelpController alloc] init];
        
        NSString *imagePath = [NSString stringWithFormat:@"help/%@", imageName];
        
        if (iPhone5)
        {
            imagePath = [imagePath stringByReplacingOccurrencesOfString:@".png"
                                                             withString:@"-568h.png"];
        }
        
        NSLog(@"imagePath:%@", imagePath);
        
        UIImage *image = [UIImage imageNamed:imagePath];
        
        helpController.image = image;
        
        [_helpPages addPagedViewController:helpController];
    }
    
    [self _setupSkip];
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
 获取帮助所有图片
 */
- (NSArray *) _helpImageNames
{    
    NSBundle *defaultBundle = [NSBundle mainBundle];
    
    NSArray *helpImageNames = [defaultBundle picturesWithDirectoryName:@"help"];
    
    NSArray *helpImageNamesSortedByName = [helpImageNames sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1,
                                                                                                         NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    if (!helpImageNamesSortedByName ||
        [helpImageNamesSortedByName count] == 0)
        return nil;
    
    return helpImageNamesSortedByName;
}

- (void) _skip
{
    if ([self.delegate respondsToSelector:@selector(helpFinished:)])
    {
        [self.delegate helpFinished:self];
    }
}

/* 
 初始化跳过按钮
 */
- (void) _setupSkip
{
    NSString *imageNormalFile = [[NSBundle mainBundle] pictureWithDirectoryName:@"help/skip/normal"];
    NSString *imageHighlightedFile = [[NSBundle mainBundle] pictureWithDirectoryName:@"help/skip/highlighted"];
    
    if (!imageNormalFile)
    {
        _skip.hidden = YES;
        
        NSInfo(@"没有图片，所以不显示跳过按钮");
        
        return;
    }
    
    UIImage *imageNormal = [UIImage imageNamed:[imageNormalFile valueForFileInPath:@"help/skip/normal"]];
    UIImage *imageHighlighted = [UIImage imageNamed:[imageHighlightedFile valueForFileInPath:@"help/skip/highlighted"]];
    
    CGRect normalFrame = _skip.frame;
    
    CGRect imageNormalRect = [imageNormalFile CGRectForFile];
    
    // 默认使用图片大小
    normalFrame.size.width = imageNormal.size.width;
    
    normalFrame.size.height = imageNormal.size.height;
    
    // 如果有用户设置则覆盖
    normalFrame.origin.x = imageNormalRect.origin.x != 0 ? imageNormalRect.origin.x : normalFrame.origin.x;
    
    normalFrame.origin.y = imageNormalRect.origin.y != 0 ? imageNormalRect.origin.y : normalFrame.origin.y;
    
    normalFrame.size.width = imageNormalRect.size.width != 0 ? imageNormalRect.size.width : normalFrame.size.width;
    
    normalFrame.size.height = imageNormalRect.size.height != 0 ? imageNormalRect.size.height : normalFrame.size.height;
    
    _skip.frame = normalFrame;
    
    [_skip setImage:imageNormal
           forState:UIControlStateNormal];
    
    [_skip setImage:imageHighlighted
           forState:UIControlStateHighlighted];
}

#pragma mark - 公有 -

+ (void) markHelped:(BOOL)helped
{
    [[NSUserDefaults standardUserDefaults] setBool:helped
                                            forKey:WPHELPVIEW_MARKHELPED];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSInfo(@"帮助标示被重置为%@", helped ? @"看过" : @"没看过");
}

+ (BOOL) helped
{
    NSNumber *helped = [[NSUserDefaults standardUserDefaults] objectForKey:WPHELPVIEW_MARKHELPED];
    
    if (!helped)
        return NO;
    
    return helped.boolValue;
}

#pragma mark - FireUIPagedScrollViewDelegate -
- (void) firePagerEnd:(FireUIPagedScrollView*)pager
{
    [self _skip];
}

#pragma mark - IBAction -

- (IBAction) onSkip:(UIButton *)sender
{
    [self _skip];
}

@end

@interface WPHelpController ()

@property (strong, nonatomic) UIImageView *helpImageView;

@end

@implementation WPHelpController

- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if (self)
    {
        _helpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       [UIScreen mainScreen].bounds.size.width,
                                                                       [UIScreen mainScreen].bounds.size.height)];
        
        _helpImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleBottomMargin ;
        
        _helpImageView.contentMode = UIViewContentModeTop;
    }
    
    return self;
}

- (void) viewDidLoad
{
    _helpImageView.image = _image;
    
    [self.view addSubview:_helpImageView];
}

@end