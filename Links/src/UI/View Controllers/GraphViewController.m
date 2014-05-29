//
//  GraphViewController.m
//  Links
//
//  Created by Eoin Nolan on 27/04/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#include "AppDelegate.h"
#import "GraphViewController.h"
#import "Definitions.h"
#import "BookViewController.h"
#import "UIBezierPath+Smoothing.h"
#import "SentimentCell.h"
#import "MBProgressHUD.h"

@interface GraphViewController ()
@property NSDictionary * sentimentData;
@property IBOutlet UITableView * chapterTable;
@property IBOutlet UIScrollView * graphView;
@property float currentStepSize;
@property float currentSectionSize;
@property UIView * highLightView;
@property UITapGestureRecognizer * gestureRecognizer;
@property float touchLocation;
@property BOOL layout;
@end

static float scale = 2;

@implementation GraphViewController

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
    _layout = false;
    [super viewDidLoad];
    [self setupUI];
    _currentStepSize = 50;
    _currentSectionSize = 100;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(__bridge id)((void*)UIInterfaceOrientationLandscapeLeft)];
    _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [_gestureRecognizer setNumberOfTapsRequired:2.0];
    [_graphView addGestureRecognizer:_gestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    if (_layout == false) {
        MBProgressHUD * HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        [HUD showWhileExecuting:@selector(reloadGraph) onTarget:self withObject:nil animated:YES];
        _layout = true;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [_graphView removeGestureRecognizer:_gestureRecognizer];
    _gestureRecognizer = nil;
}

- (void)setupUI {
    _highLightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
    [_highLightView setBackgroundColor:UI_HIGHLIGHT_BLUE];
    [_highLightView setAlpha:0.3f];
    [_chapterTable addSubview:_highLightView];
}

- (void)reloadData {
    [_chapterTable reloadData];
}

- (void)reloadGraph {
    NSLog(@"Reload Graph");

    NSLog(@"Graph Size : %f * %f", _graphView.frame.size.width, _graphView.frame.size.height);
    [_graphView setFrame:CGRectMake(260, 0, 768, 768)];
    [_graphView setContentSize:CGSizeMake(_currentStepSize * self.book.positiveSentiment.count, 100)];
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    UIBezierPath * negPath = [UIBezierPath bezierPath];
    UIBezierPath * avPath = [UIBezierPath bezierPath];
    
    float midY = 704 / 2;
    float x = _currentStepSize;
    
    [path moveToPoint:CGPointMake(0, midY)];
    [negPath moveToPoint:CGPointMake(0, midY)];
    [avPath moveToPoint:CGPointMake(0, midY)];
    
    for (int i = 0; i < self.book.positiveSentiment.count; ++i) {
        NSNumber * pos = [self.book.positiveSentiment objectAtIndex:i];
        NSNumber * neg = [self.book.negativeSentiment objectAtIndex:i];
        
        float py = midY + midY * scale * (-[pos floatValue]);
        float ny = midY + midY * scale * (-[neg floatValue]);
        
        [path addLineToPoint:CGPointMake(x, py)];
        [negPath addLineToPoint:CGPointMake(x, ny)];
        [avPath addLineToPoint:CGPointMake(x, (py+ny) / 2)];
        x += _currentStepSize;
        
    }
//    
//    for (NSNumber * n in self.book.sentiment) {
//        //NSLog(@"Senti Point : %f", [n floatValue]);
//        float y = midY + midY * scale * (-[n floatValue]);
//        //NSLog(@"Graph Point : %f", y);
//        [path addLineToPoint:CGPointMake(x, y)];
//        x += _currentStepSize;
//    }
    
    [path addLineToPoint:CGPointMake(x, midY)];
    [negPath addLineToPoint:CGPointMake(x, midY)];
    
    UIBezierPath * positivePath = path;//[path smoothedPathWithGranularity:20];
    UIBezierPath * negativePath = negPath;//[negPath smoothedPathWithGranularity:20];
    UIBezierPath * ap = [avPath smoothedPathWithGranularity:4];
    
    UIBezierPath * centerPath = [UIBezierPath bezierPath];
    [centerPath moveToPoint:CGPointMake(0, midY)];
    [centerPath addLineToPoint:CGPointMake(_graphView.contentSize.width, midY)];
    
    CAShapeLayer * centerLayer = [CAShapeLayer layer];
    centerLayer.path = [centerPath CGPath];
    centerLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
    centerLayer.lineWidth = 2.0;
    
    CAShapeLayer * maskLayer1 = [CAShapeLayer layer];
    maskLayer1.path = [positivePath CGPath];
    maskLayer1.fillColor = [[UIColor whiteColor] CGColor];
    
    CAShapeLayer * maskLayer2 = [CAShapeLayer layer];
    maskLayer2.path = [negativePath CGPath];
    maskLayer2.fillColor = [[UIColor whiteColor] CGColor];
    
    CAShapeLayer *strokeLayer1 = [CAShapeLayer layer];
    strokeLayer1.path = [positivePath CGPath];
    strokeLayer1.strokeColor = [[UIColor lightGrayColor] CGColor];
    strokeLayer1.lineWidth = 2.0;
    strokeLayer1.fillColor = [UIColorFromRGB(0x466289)  CGColor];
    
    CAShapeLayer *strokeLayer2 = [CAShapeLayer layer];
    strokeLayer2.path = [negativePath CGPath];
    strokeLayer2.strokeColor = [[UIColor lightGrayColor] CGColor];
    strokeLayer2.lineWidth = 2.0;
    strokeLayer2.fillColor = [UIColorFromRGB(0xfa6121) CGColor];
    
    CAShapeLayer *avLayer = [CAShapeLayer layer];
    avLayer.path = [ap CGPath];
    avLayer.strokeColor = [[UIColor whiteColor] CGColor];
    avLayer.lineWidth = 4.0;
    avLayer.fillColor = [[UIColor clearColor] CGColor];
    
    //[self addGridLines];
    NSLog(@"MAX : %f, MIN : %f", self.book.maxSentiment, self.book.minSentiment);
    UIBezierPath * maxPath = [UIBezierPath bezierPath];
    [maxPath moveToPoint:CGPointMake(0, midY + midY * scale * -self.book.maxSentiment)];
    [maxPath addLineToPoint:CGPointMake(_graphView.contentSize.width, midY + midY * scale * -self.book.maxSentiment)];
    
    UIBezierPath * minPath = [UIBezierPath bezierPath];
    [minPath moveToPoint:CGPointMake(0, midY + midY * scale * -self.book.minSentiment)];
    [minPath addLineToPoint:CGPointMake(_graphView.contentSize.width, midY + midY * scale * -self.book.minSentiment)];
    
    CAShapeLayer * max = [CAShapeLayer layer];
    max.path = [maxPath CGPath];
    max.strokeColor = [UIColorFromRGB(0x1f391f) CGColor];
    max.lineWidth = 1.0;
    
    CAShapeLayer * min = [CAShapeLayer layer];
    min.path = [minPath CGPath];
    min.strokeColor = [UIColorFromRGB(0x391f1f) CGColor];
    min.lineWidth = 1.0;
    


    [_graphView.layer addSublayer:max];
    [_graphView.layer addSublayer:min];
    [_graphView.layer addSublayer:centerLayer];
    [_graphView.layer addSublayer:strokeLayer1];
    [_graphView.layer addSublayer:strokeLayer2];
    [_graphView.layer addSublayer:avLayer];
    
    [self addChapterNames];
    
}

- (void)addChapterNames {
    UIBezierPath * pt = [UIBezierPath bezierPath];
    for (int i = 0; i < [self.book.chapterNames count]; ++i) {
        NSNumber * location = [self.book.chapterLocations objectAtIndex:i];
        float x = ([location floatValue] / [self.book.text length]) * _graphView.contentSize.width;
        float y = _graphView.frame.size.height;
        
        
        [pt moveToPoint:CGPointMake(x, 0)];
        [pt addLineToPoint:CGPointMake(x, y)];
        
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(x+10, 10, 200, 50)];
        [lbl setText:[self.book.chapterNames objectAtIndex:i]];
        [lbl setTextColor:[UIColor whiteColor]];
        [_graphView addSubview:lbl];
    }
    
    CAShapeLayer * sl = [CAShapeLayer layer];
    sl.path = [pt CGPath];
    sl.strokeColor = [[UIColor whiteColor] CGColor];
    sl.lineWidth = 2.0;
    sl.fillColor = [[UIColor clearColor] CGColor];
    [_graphView.layer addSublayer:sl];
}

- (void)addGridLines {
    float verticalStep = _graphView.frame.size.height/10;
    UIBezierPath * gridLine = [UIBezierPath bezierPath];
    for (int i = 1; i < 10; ++i) {
        if (i == 5) continue; //No centre line
        [gridLine moveToPoint:CGPointMake(0, verticalStep * i)];
        [gridLine addLineToPoint:CGPointMake(_graphView.contentSize.width, verticalStep * i)];
        
    }
    CAShapeLayer * gridLayer = [CAShapeLayer layer];
    gridLayer.path = [gridLine CGPath];
    gridLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
    gridLayer.lineWidth = 1.0;
    [gridLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:10], [NSNumber numberWithInt:5],nil]];
    [_graphView.layer addSublayer:gridLayer];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.book == Nil) {
        return 0;
    } else {
        return self.book.chapterNames.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"ChapterCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.textLabel setText:[self.book.chapterNames objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSNumber * chapterLocation = [self.book.chapterLocations objectAtIndex:indexPath.row];
    
    float offset = ([chapterLocation floatValue] / [self.book.text length]) * _graphView.contentSize.width;
    
    [_graphView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.book.chapterLocations.count == 0) {
        return;
    }
    float x = scrollView.contentOffset.x;
    int i;
    for (i = 0; i < self.book.chapterLocations.count; ++i) {
        NSNumber * location = [self.book.chapterLocations objectAtIndex:i];
        if (x+2 < ([location floatValue] / [self.book.text length]) * _graphView.contentSize.width) {
            break;
        }
    }
    CGRect rect = [_chapterTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:MAX(0, i-1) inSection:0]];
    [_highLightView setFrame:rect];
    
}

-  (void)handleTap:(UITapGestureRecognizer*)sender {
    NSLog(@"Double Tap");
    CGPoint point = [sender locationInView:_graphView];
    NSLog(@"Touch at %f, %f", point.x, point.y);
    _touchLocation = point.x;
    [self performSegueWithIdentifier:@"OpenBookSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OpenBookSegue"]) {
        BookViewController * bvc = [segue destinationViewController];
        [bvc setBook:self.book];
        [bvc setScrollPosition:self.book.text.length * (_touchLocation/_graphView.contentSize.width)];

        
        
        NSNumber * scrollLoc = [NSNumber numberWithFloat:self.book.text.length * (_touchLocation/_graphView.contentSize.width)];
//        
//        int rangeIndex = floorf([scrollLoc floatValue] / _currentSectionSize);
//        NSLog(@"Range index : %d", rangeIndex);
//        NSLog(@"Total Sentiment : %d, locations %d", self.book.sentiment.count, self.book.sentimentOffsets.count);
//        int rangeStart = [[self.book.sentimentOffsets objectAtIndex:rangeIndex] integerValue];
//        
//        int rangeSize = (rangeIndex >= self.book.sentimentOffsets.count-4) ? self.book.text.length : [[self.book.sentimentOffsets objectAtIndex:rangeIndex+3] integerValue] ;
//        rangeSize -= rangeStart;
        //this is such terrible code, i'm tired
        int rangeStart, rangeSize;
        rangeSize = 0; rangeStart = 0;
        int rangeIndex = 0;
        for (int i = 0; i < self.book.sentimentOffsets.count; ++i) {
            //NSLog(@"%f > %f", [[self.book.sentimentOffsets objectAtIndex:i] floatValue], [scrollLoc floatValue]);
            if ([[self.book.sentimentOffsets objectAtIndex:i] floatValue] > [scrollLoc floatValue]) {
                rangeStart = [[self.book.sentimentOffsets objectAtIndex:i-1] integerValue];
                rangeIndex = i-1;
                break;
            }
        }
        
        rangeSize = [[self.book.sentimentOffsets objectAtIndex:(rangeIndex+3)] integerValue] - rangeStart;
        
        [bvc setRange:NSMakeRange(rangeStart, rangeSize)];
        NSLog(@"Number of positions : %d", self.book.sentimentOffsets.count);
        NSLog(@"ScrollPosition = %f :: Range = loc %d, len: %d", self.book.text.length * (_touchLocation/_graphView.contentSize.width), rangeStart, rangeSize);
    }

}

- (void)loadSentimentData {
    NSString * filePath = [[NSBundle mainBundle] pathForResource:SENTIMENT_DATASET ofType:@"data"];
    _sentimentData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

#pragma mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.book.positiveSentiment count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SentimentCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SentimentCell" forIndexPath:indexPath];
    
    NSNumber * psentiment = [self.book.positiveSentiment objectAtIndex:indexPath.row];
    NSNumber * nsentiment = [self.book.negativeSentiment objectAtIndex:indexPath.row];
    

        float h1 = 350 * ([psentiment floatValue]);
        cell.positiveView.frame = CGRectMake(0, 350 - h1, 50, h1);

        

        float h2 = -350 * ([nsentiment floatValue] );
        cell.negativeView.frame = CGRectMake(0, 350, 50, h2);


    
    return cell;
}

@end
