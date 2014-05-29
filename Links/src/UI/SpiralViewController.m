//
//  SpiralViewController.m
//  Links
//
//  Created by Eoin Nolan on 18/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import "SpiralViewController.h"
#import "UISpiralView.h"
#import "Logger.h"
#import "CircleView.h"
#import "Node.h"
#import "Edge.h"
#include "Definitions.h"
#import "BookCollection.h"
#import "VisualisationTabBarController.h"

@interface SpiralViewController ()
@property IBOutlet UISpiralView * spiralView;
@property BOOL lockScrollRefresh;
@property NSMutableDictionary * wordDictionary;
@property NSArray * nodes;
@property NSInteger selectedIndex;
@end

@implementation SpiralViewController
@synthesize spiralView, lockScrollRefresh, wordDictionary;
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
    wordDictionary = [NSMutableDictionary dictionary];
	LOG_i(@"SpiralViewController loaded");
    lockScrollRefresh = NO;
    [self.view setMinimumZoomScale:0.25];
    [self.view setMaximumZoomScale:10.0];
    [self.view setZoomScale:1];
    [self.view setContentSize:CGSizeMake(MAXSIZE, MAXSIZE)];
    [self.view setContentOffset:CGPointMake(MAXSIZE/2-384, MAXSIZE/2-512)];
    VisualisationTabBarController * parent = (VisualisationTabBarController *)[self tabBarController];
    _collection = parent.collection;
    _nodes = [_collection applyFilters];
    _selectedIndex = -1;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.view reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return (UIView *)self.view.baseView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    lockScrollRefresh = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.view renderVisibleSubviewAtScale:scrollView.zoomScale x:scrollView.contentOffset.x y:scrollView.contentOffset.y shouldRedraw:NO];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [scrollView setContentSize:CGSizeMake(MAXSIZE * scale, MAXSIZE * scale)];
    [self.view renderVisibleSubviewAtScale:scale x:scrollView.contentOffset.x y:scrollView.contentOffset.y shouldRedraw:YES];
    lockScrollRefresh = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!lockScrollRefresh) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self.view renderVisibleSubviewAtScale:scrollView.zoomScale x:scrollView.contentOffset.x y:scrollView.contentOffset.y shouldRedraw:YES];
    }
}

- (void)reloadData {
    if (self.collection.lastResults == nil) {
        [self.collection applyFilters];
    }
    _nodes = [self.collection lastResults];
    [self.view reloadData];
}

#pragma UISpiralViewDelegate
- (NSUInteger)numberOfViewsInSpiral {
    return [_nodes count];
}
- (UIView *)subViewForIndex:(NSUInteger)index {
    CGFloat side = MAX_CIRCLE_WIDTH * ([self getFrequencyForIndex:index] / [self getMaxFrequency]);
    side = side < 50 ? 50: side;
    CGRect frame = CGRectMake(0, 0, side, side);
    Node * node = (Node *)[_nodes objectAtIndex:index];
    [wordDictionary setObject:@(index) forKey:@(node.key)];
    CircleView * circleView = [[CircleView alloc] initWithFrame:frame andNode:node andIndex:index];
    return circleView;
    
}
- (CGFloat)getMaxFrequency {
    if ([_nodes count] > 0) {
        Node * node = [_nodes objectAtIndex:0];
        return node.frequency;
    } else {
        NSLog(@"ERROR RETURNING 0 MAX FREQ");
        return 0;
    }
}
- (CGFloat)getFrequencyForIndex:(NSUInteger)index {
    CGFloat minFrequency = (50 * [self getMaxFrequency]) / MAX_CIRCLE_WIDTH;
    CGFloat thisFrequency = [(Node *)[_nodes objectAtIndex:index] frequency];
    return thisFrequency < minFrequency ? minFrequency : thisFrequency;
}
- (void)didSelectViewAtIndex:(NSUInteger)index {
    NSLog(@"Did select view at : %lu", (unsigned long)index);
    [spiralView unhighlightAll];
    [spiralView highlightViewAtIndex:index weight:1];
    Node * selectedNode = [_nodes objectAtIndex:index];
    
    float weight = 1;
    if ([[selectedNode getAllEdges] count] > 0) {
        Edge * e = [[selectedNode getAllEdges] objectAtIndex:0];
        weight = e.weight;
    }
    for (Edge * edge in [selectedNode getAllEdges]) {
        Node * adjacent = [edge getAdjacentNodeTo:selectedNode];
        NSNumber * n = [wordDictionary objectForKey:@(adjacent.key)];
        if (n != nil && ((float)edge.weight / weight) >= 0.10) {
            [spiralView highlightViewAtIndex:[n integerValue] weight:(float)edge.weight / weight];
        }
    }
}

- (void)didDeselectViewAtIndex:(NSUInteger)index {
    [spiralView unhighlightAll];
}

@end
