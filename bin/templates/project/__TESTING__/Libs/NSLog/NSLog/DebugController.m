//
//  WPDebugController.m
//  ECMobile
//
//  Created by 张 舰 on 2/27/13.
//
//

#import "DebugController.h"

#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#include <libgen.h>

#import "Log.h"

#define kWPDebugController_LogsDir  @"/tmp/logs/"

typedef enum {
    LogTypeDebug,
    LogTypeInfo,
    LogTypeWarn,
} LogType ;

typedef void (^LogWithType)(NSString *log, LogType type) ;

@interface DebugController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UITextView *debugView;
@property (strong, nonatomic) UITextView *infoView;
@property (strong, nonatomic) UITextView *warnView;
@property (strong, nonatomic) UIButton *sendToEmail;
@property (strong, nonatomic) UIButton *changeDebug;
@property (strong, nonatomic) UIButton *changeInfo;
@property (strong, nonatomic) UIButton *changeWarn;
@property (strong, nonatomic) NSString *lastLogFileName;

@end

@implementation DebugController

#pragma mark - 公有 -

+ (void) openLog
{
    NSString *logsDirPath = [NSHomeDirectory() stringByAppendingPathComponent:kWPDebugController_LogsDir];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:logsDirPath] == NO)
    {
        __autoreleasing NSError *error;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:logsDirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
        if (error)
        {
            NSLog(@"文件夹创建失败");
            return;
        }
    }
    
    // 根据时间来命名log文件
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *fileName = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.log",
                                                                            kWPDebugController_LogsDir,
                                                                            fileName]];
    
    freopen([filePath cStringUsingEncoding:NSUTF8StringEncoding],
            "w",
            stderr);
}

#pragma mark - 继承 -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _initNib];

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(_exitDebug:)];
    
    swipe.numberOfTouchesRequired = 2;
    
    [self.view addGestureRecognizer:swipe];
    
    [self _handleLastLog];
    
//    [self _test];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
}

#pragma mark - 私有 -

- (void) _initNib
{
    self.view.backgroundColor = [UIColor blackColor];
    
    // textview debug
    UITextView *debugView = [self _textViewInit];
    
    debugView.hidden = NO;
    
    [self.view addSubview:debugView];
    
    _debugView = debugView;
    
    // textview info
    UITextView *infoView = [self _textViewInit];
    
    infoView.hidden = YES;
    
    [self.view addSubview:infoView];
    
    _infoView = infoView;
    
    // textview warn
    UITextView *warnView = [self _textViewInit];
    
    warnView.hidden = YES;
    
    [self.view addSubview:warnView];
    
    _warnView = warnView;
    
    // button Email
    UIButton *sendToEmail = [self _buttonInitWithTitle:@"Email"
                                                 frame:CGRectMake(272,
                                                                  436,
                                                                  44,
                                                                  44)
                                                action:@selector(onSendEmail:)];
    
    [self.view addSubview:sendToEmail];
    
    _sendToEmail = sendToEmail;
    
    // button debug
    UIButton *changeDebug = [self _buttonInitWithTitle:@"Debug"
                                                 frame:CGRectMake(0,
                                                                  436,
                                                                  44,
                                                                  44)
                                                action:@selector(onChangeDebug:)];
    
    [self.view addSubview:changeDebug];
    
    _changeDebug = changeDebug;
    
    // button info
    UIButton *changeInfo = [self _buttonInitWithTitle:@"Info"
                                                 frame:CGRectMake(50,
                                                                  436,
                                                                  44,
                                                                  44)
                                                action:@selector(onChangeInfo:)];
    
    [self.view addSubview:changeInfo];
    
    _changeInfo = changeInfo;
    
    // button warn
    UIButton *changeWarn = [self _buttonInitWithTitle:@"Warn"
                                                frame:CGRectMake(100,
                                                                 436,
                                                                 44,
                                                                 44)
                                               action:@selector(onChangeWarn:)];
    
    [self.view addSubview:changeWarn];
    
    _changeWarn = changeWarn;
}

- (UITextView *) _textViewInit
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         0.0f,
                                                                         320.0f,
                                                                         436.0f)];
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleBottomMargin;
    
    textView.textColor = [UIColor whiteColor];
    
    textView.backgroundColor = [UIColor clearColor];
    
    textView.font = [UIFont systemFontOfSize:14.0f];
    
    textView.editable = NO;
    
    return textView;
}

- (UIButton *) _buttonInitWithTitle:(NSString *)title
                              frame:(CGRect)frame
                             action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    button.frame = frame;
    
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    
    button.titleLabel.textColor = [UIColor whiteColor];
    
    button.layer.borderWidth = 1.0f;
    
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void) _exitDebug:(UISwipeGestureRecognizer *)swpie
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) _handleLastLog
{
    NSString *logFilesDir = [NSHomeDirectory() stringByAppendingPathComponent:kWPDebugController_LogsDir];
    
    // 所有logs文件
    NSArray *logFilePaths = [[NSFileManager defaultManager] subpathsAtPath:logFilesDir];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // 排序后的logs
    NSArray *sortedLogFilePaths = [logFilePaths sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1,
                                                                                               NSString *obj2) {
        NSString *file1Name = [obj1 stringByDeletingPathExtension];
        
        NSString *file2Name = [obj2 stringByDeletingPathExtension];
        
        NSDate *date1 = [dateFormatter dateFromString:file1Name];
        
        NSDate *date2 = [dateFormatter dateFromString:file2Name];
        
        return [date1 compare:date2];
    }];
    
    // 最后一个log
    _lastLogFileName = [sortedLogFilePaths lastObject];
    
    NSString *lastLogFilePath = [NSString stringWithFormat:@"%@/%@", logFilesDir,[sortedLogFilePaths lastObject]];
    
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:lastLogFilePath];
    
    [handle readInBackgroundAndNotify];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_logUpdate:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:nil];
}

- (void) _logUpdate:(NSNotification *)nofitication
{
    NSFileHandle *handle = nofitication.object;
    
    // 获得新log
    NSData *data = [nofitication.userInfo objectForKey:NSFileHandleNotificationDataItem];
    
    NSString *string = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    
    // 数据分组
    [self _logsWithString:string
               logAndType:^(NSString *log,
                            LogType type) {
                   // 没组区分log级别
                   switch (type) {
                       case LogTypeDebug:
                       {
                           _debugView.text = [_debugView.text stringByAppendingString:log];
                           
                           break;
                       }
                       case LogTypeInfo:
                       {
                           _debugView.text = [_debugView.text stringByAppendingString:log];
                           
                           _infoView.text = [_infoView.text stringByAppendingString:log];
                           
                           break;
                       }
                       case LogTypeWarn:
                       {
                           _debugView.text = [_debugView.text stringByAppendingString:log];
                           
                           _infoView.text = [_infoView.text stringByAppendingString:log];
                           
                           _warnView.text = [_warnView.text stringByAppendingString:log];
                           
                           break;
                       }
                       default:
                       {
                           break;
                       }
                   }
    }];
    
    // 停留在最后则跟随
    CGFloat moreHeight = _debugView.bounds.size.height * 1.0f;
    
    if (_debugView.contentOffset.y + _debugView.bounds.size.height + moreHeight >= _debugView.contentSize.height)
    {
        [self performSelectorOnMainThread:@selector(_scrolltoLast)
                               withObject:nil
                            waitUntilDone:YES];
    }

    [handle performSelector:@selector(readInBackgroundAndNotify)
                 withObject:nil
                 afterDelay:1.0f];
}

- (void) _scrolltoLast
{
    NSRange range;
    range.location = [_debugView.text length] - 1;
    range.length = 0;
    
    [_debugView scrollRangeToVisible:range];
}

- (void) _logsWithString:(NSString *)logString
                  logAndType:(LogWithType)type
{
    NSString *boundName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    
    NSArray *logsData = [logString componentsSeparatedByString:[NSString stringWithFormat:@" %@", boundName]];
    
    NSArray *logsDa = [logsData objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1,
                                                                                                  [logsData count] - 1)]];
        
    for (int i = 0; i < [logsDa count]; i++)
    {
        NSString *log = nil;
        
        NSString *logDa = [logsDa objectAtIndex:i];
        
        // 寻找第一个]
        NSRange removeRange = [logDa rangeOfString:@"]"];
        
        NSString *logRemovePrefix = [logDa substringFromIndex:removeRange.location + 1];
        
        if (i == [logsDa count] - 1)
        {
            NSString *logRemoveSuffix = [logRemovePrefix substringToIndex:logRemovePrefix.length - 1];
            
            log = logRemoveSuffix;
        }
        else
        {
            NSString *logRemoveSuffix = [logRemovePrefix substringToIndex:logRemovePrefix.length - 24];
            
            log = logRemoveSuffix;
        }
        
        log = [log stringByAppendingString:@"\n"];
        
        if ([[log stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] hasPrefix:@"[Info]:"])
        {
            type(log, LogTypeInfo);
        }
        else if ([[log stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] hasPrefix:@"[Warn]:"])
        {
            type(log, LogTypeWarn);
        }
        else
        {
            type(log, LogTypeDebug);
        }
    }
}

- (void) _test
{
    NSLog(@"不断的测试一下log信息");
    
    NSInfo(@"可以测试吗 %@ and %@",@"xxx",@"ttt");
    
    NSWarn(@"%@",_debugView);
    
    [self performSelector:@selector(_test)
               withObject:nil
               afterDelay:1.0];
}

#pragma mark - MFMailComposeViewControllerDelegate -
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark - IBAction -

- (IBAction) onSendEmail:(UIButton *)sender
{
    if (![MFMailComposeViewController canSendMail])
    {
        NSMutableString *emailData = [[NSMutableString alloc] initWithString:@"mailto:?"];
        
        //添加主题
        [emailData appendFormat:@"subject=%@",_lastLogFileName];
        
        //添加邮件内容
        [emailData appendFormat:@"&body=%@", _debugView.text];
        
        NSString* email = [emailData stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
        
        return ;
    }
    
    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    
    mail.mailComposeDelegate = self;
    
    [mail setSubject:_lastLogFileName];
    
    [mail setMessageBody:_debugView.text
                  isHTML:NO];
    
    [self presentModalViewController:mail
                            animated:YES];
    
}

- (IBAction) onChangeDebug:(UIButton *)sender
{
    _infoView.hidden = YES;
    
    _warnView.hidden = YES;
    
    _debugView.hidden = NO;
}

- (IBAction) onChangeInfo:(UIButton *)sender
{
    _debugView.hidden = YES;
    
    _warnView.hidden = YES;
    
    _infoView.hidden = NO;
}

- (IBAction) onChangeWarn:(UIButton *)sender
{
    _debugView.hidden = YES;
    
    _infoView.hidden = YES;
    
    _warnView.hidden = NO;
}

@end

@implementation UIViewController (Debug)

- (void) debugStart
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(_goDebug:)];
    
    swipe.numberOfTouchesRequired = 2;
    
    [self.view addGestureRecognizer:swipe];
}

- (void) _goDebug:(UISwipeGestureRecognizer *)swpie
{
    DebugController *debug = [[DebugController alloc] init];
    
    [self presentModalViewController:debug
                            animated:YES];
}

@end

