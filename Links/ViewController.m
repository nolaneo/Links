//
//  ViewController.m
//  Links
//
//  Created by Eoin Nolan on 17/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import "ViewController.h"
#import "SpiralViewController.h"
#import "GraphViewController.h"
#import "Logger.h"
#import "Book.h"
#import "Edge.h"
#import "Node.h"
#import "BookInfo.h"

#import "UIBezierPath+Smoothing.h"

@interface ViewController ()
@property IBOutlet UILabel * statusLabel;
@property IBOutlet UIProgressView * progressView;
@property IBOutlet UIButton * spiralButton;
@property Book * test;
@end

@implementation ViewController
@synthesize progressView, statusLabel, test;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self testBook];
//    [self parseSentiment];
//    [self checkSentimentData];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)testBook {
    [progressView setProgress:0];
    [statusLabel setText:@"Initial Processing & Tokenization Book"];
    test = [Book bookWithFilename:@"brown_fiction" filetype:@"txt"];
    [test setDelegate:self];
    [test performSelectorInBackground:@selector(processBookWithCompletion:) withObject:^(NSString *result) {
        [progressView setProgress:100];
        //[self performSegueWithIdentifier:@"GraphSegue" sender:self];
        NSLog(@"COMPLETE");
    }];
}

//- (void)testSentimentGraph {
//    
//    NSLog(@"Sentiement chunks : %lu, total words : %lu", (unsigned long)[test.sentiment count], (unsigned long)test.wordCount);
//    
//    UIScrollView * graph = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
//    [graph setBackgroundColor:[UIColor darkGrayColor]];
//    [graph setContentSize:CGSizeMake(768, 50 * (test.sentiment.count))];
//    UIBezierPath * path = [UIBezierPath bezierPath];
//                                           
//    [path moveToPoint:CGPointMake(384, 0)];
//    float yOffset = 50;
//    float y = yOffset;
//    for (NSNumber * n in test.sentiment) {
//        NSLog(@"%f", [n floatValue]);
//        float x = 384 + 384 * ([n floatValue] / 5.0);
//        [path addLineToPoint:CGPointMake(x, y)];
//        y += yOffset;
//    }
//    [path addLineToPoint:CGPointMake(384, y)];
//    UIBezierPath * newPath = [path smoothedPathWithGranularity:20];
//    NSLog(@"Y = %f", y);
//    
//    UIBezierPath * centerPath = [UIBezierPath bezierPath];
//    [centerPath moveToPoint:CGPointMake(384, 0)];
//    [centerPath addLineToPoint:CGPointMake(384, graph.contentSize.height)];
//    
//    CAShapeLayer * centerLayer = [CAShapeLayer layer];
//    centerLayer.path = [centerPath CGPath];
//    centerLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
//    centerLayer.lineWidth = 2.0;
//    
//    CAShapeLayer * maskLayer = [CAShapeLayer layer];
//    maskLayer.path = [newPath CGPath];
//    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
//    
//    CAShapeLayer *strokeLayer = [CAShapeLayer layer];
//    strokeLayer.path = [newPath CGPath];
//    strokeLayer.strokeColor = [[UIColor whiteColor] CGColor];
//    strokeLayer.lineWidth = 2.0;
//    strokeLayer.fillColor = [[UIColor clearColor] CGColor];
//    
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.endPoint = CGPointMake(1.0,0.5);
//    gradientLayer.startPoint = CGPointMake(0.0,0.5);
//    gradientLayer.frame = CGRectMake(0, 0, graph.contentSize.width, graph.contentSize.height);
//    NSMutableArray *colors = [NSMutableArray array];
//    [colors addObject:(id)[[UIColor redColor] CGColor]];
//    [colors addObject:(id)[[UIColor greenColor] CGColor]];
//    gradientLayer.colors = colors;
//    
//    [gradientLayer setMask:maskLayer];
//    
//    [graph.layer addSublayer:gradientLayer];
//    
//    [graph.layer addSublayer:centerLayer];
//    
//    [graph.layer addSublayer:strokeLayer];
//    
//    
//    for (int i = 0; i < [test.chapterNames count]; ++i) {
//        NSNumber * location = [test.chapterLocations objectAtIndex:i];
//        float y = [location floatValue] / 250 * 50;
//        
//        UIBezierPath * pt = [UIBezierPath bezierPath];
//        
//        [pt moveToPoint:CGPointMake(0, y)];
//        [pt addLineToPoint:CGPointMake(768, y)];
//        
//        CAShapeLayer * sl = [CAShapeLayer layer];
//        sl.path = [pt CGPath];
//        sl.strokeColor = [[UIColor whiteColor] CGColor];
//        sl.lineWidth = 2.0;
//        sl.fillColor = [[UIColor clearColor] CGColor];
//        
//        [graph.layer addSublayer:sl];
//        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, y+5, 200, 50)];
//        [lbl setText:[test.chapterNames objectAtIndex:i]];
//        [lbl setTextColor:[UIColor whiteColor]];
//        [graph addSubview:lbl];
//    }
//    
//    [self.view addSubview:graph];
//}

- (void)parseSentiment {
    NSLog(@"Loading Sentement");
    NSString * path = [[NSBundle mainBundle] pathForResource:@"SentiWordNet" ofType:@"csv"];
    NSString * content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSArray * values = [content componentsSeparatedByString:@","];
    NSMutableDictionary * senticDictionary = [NSMutableDictionary dictionaryWithCapacity:30000];
    for (int i = 0; i+1 < [values count]; i+=2) {
        NSString * wordA = [values objectAtIndex:i];
        NSString * word = [wordA stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSString * str_number = [values objectAtIndex:i+1];
        NSNumber * number = [NSNumber numberWithFloat:[str_number floatValue]];
        [senticDictionary setObject:number forKey:word];
    }
    NSString * filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"SentiWordNet.data"];
    if ([NSKeyedArchiver archiveRootObject:senticDictionary toFile:filePath]) {
        NSLog(@"Sentiment sucessfully saved to file. There are %d entries.", [senticDictionary count]);
    } else {
        NSLog(@"ERROR: SenticNet not saved to file.");
    }
}

- (void)checkSentimentData {
    NSString * filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"SentiWordNet.data"];
    NSMutableDictionary * senticNet = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    for (NSString * word in [senticNet allKeys]) {
        NSNumber * value = [senticNet objectForKey:word];
        NSLog(@"|%@| %f", word, [value floatValue]);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"%@",[segue identifier]);
    if ([[segue identifier] isEqualToString:@"SpiralSegue"]) {
        SpiralViewController * viewController = [segue destinationViewController];
        [viewController setBook:test];
    }
    if ([[segue identifier] isEqualToString:@"GraphSegue"]) {
        GraphViewController * viewController = [segue destinationViewController];
        [viewController setBook:test];
    }
}

#pragma BookProcessingDelegate
- (void)updateTokenizationProgress:(NSNumber *)progress {
    [progressView setProgress:[progress floatValue]];
}
- (void)updateGraphCreationProgress:(NSNumber *)progress {
    [progressView setProgress:[progress floatValue]];
}
- (void)updateStatusLabel:(NSString *)status {
    [statusLabel setText:status];
}
- (void)updateWordProcessingTotalNouns:(NSUInteger)nouns verbs:(NSUInteger)verbs adjectives:(NSUInteger)adjectives {
    
}
- (void)updateGraphProcessingWithNodes:(NSUInteger)nodes edges:(NSUInteger)edges {
    
}

- (void)updateWordProcessingTotal:(struct ProcessingUpdate)update {
    
}

@end
