//
//  CircleView.h
//  Links
//
//  Created by Eoin Nolan on 18/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Node;
@class UISpiralView;
@interface CircleView : UIView
- (id)initWithFrame:(CGRect)frame andNode:(Node *)node andIndex:(NSUInteger)index;
- (void)highlight:(BOOL)highlight weight:(float)weight;
- (void)unhighlight;
@property UISpiralView * spiral;
@property NSUInteger index;

@end
