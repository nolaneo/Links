//
//  BookViewController.m
//  Links
//
//  Created by Eoin Nolan on 01/05/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "BookViewController.h"
#import "Definitions.h"
#import "MBProgressHUD.h"

@interface BookViewController ()
@property IBOutlet UITextView * textView;
@end
static NSDictionary * sentimentData;
@implementation BookViewController



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
    MBProgressHUD * HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
    [HUD showWhileExecuting:@selector(setupText) onTarget:self withObject:nil animated:YES];
    
}

- (void)setupText {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 40.0f;
    paragraphStyle.maximumLineHeight = 40.0f;
    paragraphStyle.minimumLineHeight = 40.0f;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    
    UIFont * font = [UIFont fontWithName:@"Palatino-Roman" size:15.0];
    NSDictionary *ats = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font};
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:self.book.text attributes:ats];
    
    if (self.range.location != NSNotFound) {
        [self loadSentimentData];
        @autoreleasepool {
            [self.book.text enumerateSubstringsInRange:self.range options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                
                NSNumber * sentiment = [sentimentData objectForKey:[substring lowercaseString]];
                if (sentiment != nil) {
                    UIColor * color = [sentiment floatValue] > 0 ?
                    [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0*[sentiment floatValue]]:
                    [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:-1.0*[sentiment floatValue]];
                    [attributedString addAttribute:NSBackgroundColorAttributeName value:color range:substringRange];
                }
            }];
        }
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.attributedText = attributedString;
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(__bridge id)((void*)UIInterfaceOrientationPortrait)];  
    [self scrollToPosition:self.scrollPosition];
}


- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollToPosition:(NSUInteger)position {
    NSRange range = NSMakeRange(position,1);
    [_textView scrollRangeToVisible:range];
}

- (void)loadSentimentData {
    if (sentimentData != nil) {
        return;
    }
    NSString * filePath = [[NSBundle mainBundle] pathForResource:SENTIMENT_DATASET ofType:@"data"];
    sentimentData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

@end
