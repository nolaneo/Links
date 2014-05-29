//
//  UISpiralView.h
//  Links
//
//  Created by Eoin Nolan on 18/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UISpiralViewDelegate

- (NSUInteger)numberOfViewsInSpiral;
- (UIView *)subViewForIndex:(NSUInteger)index;
- (CGFloat)getMaxFrequency;
- (CGFloat)getFrequencyForIndex:(NSUInteger)index;
- (void)didSelectViewAtIndex:(NSUInteger)index;
- (void)didDeselectViewAtIndex:(NSUInteger)index;
@end

typedef struct SpiralVertex {
    NSInteger x;
    NSInteger y;
    CGFloat w;
} SpiralVertex;

@interface UISpiralView : UIScrollView

@property (unsafe_unretained, nonatomic) id<UISpiralViewDelegate, UIScrollViewDelegate> delegate;
@property UIView * baseView;
@property NSMutableArray * spiralVertices;

- (void)initSpiral;
- (void)reloadData;
- (void)unhighlightAll;
- (void)highlightViewAtIndex:(NSUInteger)index weight:(float)weight;
- (void)renderVisibleSubviewAtScale:(CGFloat)scale x:(CGFloat)screenX y:(CGFloat)screenY shouldRedraw:(BOOL)redraw;
- (void)didSelectIndex:(NSUInteger)index;
- (void)didDeselectIndex:(NSUInteger)index;
- (SpiralVertex)getVertex:(NSInteger)index;

@end
