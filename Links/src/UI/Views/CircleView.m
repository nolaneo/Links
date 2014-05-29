//
//  CircleView.m
//  Links
//
//  Created by Eoin Nolan on 18/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import "CircleView.h"
#include "Definitions.h"
#import "Node.h"
#import "UISpiralView.h"
#import "WordToken.h"
#import <QuartzCore/QuartzCore.h>

@interface CircleView ()
@property UIColor * currentColor;
@property CAShapeLayer * circle;
@property BOOL selected;
@property UILabel * label;
@property double touchesBegan;
@end

@implementation CircleView

@synthesize circle, label;
- (id)initWithFrame:(CGRect)frame andNode:(Node *)node andIndex:(NSUInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        self.index = index;
        [super setBackgroundColor:[UIColor clearColor]];
        _currentColor = FG_GREY;
        //int radius = frame.size.width/2;
        self.clipsToBounds = NO;
//        circle = [CAShapeLayer layer];
//        // Make a circular shape
//        circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2*radius, 2*radius)
//                                                 cornerRadius:radius].CGPath;
//        // Center the shape in self.view
//        circle.position = CGPointMake(CGRectGetMidX(frame)-radius,
//                                      CGRectGetMidY(frame)-radius);
//        
//        // Configure the apperence of the circle
//        circle.fillColor   = _currentColor.CGColor;
//        circle.strokeColor = [UIColor whiteColor].CGColor;
//        circle.lineWidth = frame.size.height/10;
//        
//        // Add to parent layer
//        [self.layer addSublayer:circle];
//        self.layer.shouldRasterize = YES;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width * 0.1, frame.size.height *  0.33, frame.size.width - (frame.size.width * 0.2), frame.size.height * 0.33)];
        [label setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        [label setAdjustsFontSizeToFitWidth:YES];
        [label setTextColor:[UIColor whiteColor]];
        [label setNumberOfLines:1];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont boldSystemFontOfSize:frame.size.height/5]];
        [label setText:node.word];
        [self addSubview:label];
        
        UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width * 0.1, frame.size.height *  0.65, frame.size.width - (frame.size.width * 0.2), frame.size.height * 0.15)];
        [label2 setAdjustsFontSizeToFitWidth:YES];
        [label2 setTextColor:FG_PEACH];
        [label2 setNumberOfLines:1];
        [label2 setTextAlignment:NSTextAlignmentCenter];
        [label2 setFont:[UIFont boldSystemFontOfSize:frame.size.height/6]];
        [label2 setText:[NSString stringWithFormat:@"%lu", (unsigned long)node.frequency]];
        [self addSubview:label2];
        
        UILabel * label3 = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width * 0.1, frame.size.height *  0.2, frame.size.width - (frame.size.width * 0.2), frame.size.height * 0.15)];
        [label3 setAdjustsFontSizeToFitWidth:YES];
        [label3 setTextColor:[UIColor lightGrayColor]];
        [label3 setNumberOfLines:1];
        [label3 setTextAlignment:NSTextAlignmentCenter];
        [label3 setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:frame.size.height/12]];
        [label3 setText:[WordToken wordTypeToString:node.wordType]];
        //[self addSubview:label3];
        
        _selected = false;
        
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    for (UIView * v in self.subviews) {
        [v setHidden:hidden];
    }
    //[circle setHidden:hidden];
}

//- (void)drawRect:(CGRect)rect {
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//        CGContextAddEllipseInRect(context, rect);
//        CGContextFillPath(context);
//}

- (void)highlight:(BOOL)highlight weight:(float)weight {
    //circle.fillColor = highlight ? [UIColor orangeColor].CGColor : [UIColor grayColor].CGColor;
    [label setBackgroundColor: highlight ? [UIColor orangeColor] : [UIColor clearColor]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchesBegan = CACurrentMediaTime();

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (CACurrentMediaTime() - _touchesBegan < 0.5) {
        return;
    }
    
    NSLog(@"Pressed node %d", self.index);
    _currentColor = [_currentColor  isEqual:FG_GREY] ? [UIColor grayColor] : FG_GREY;
    circle.fillColor = _currentColor.CGColor;
    
    if (_selected) {
        [self.spiral didDeselectIndex:self.index];
        _selected = false;
    } else {
        [self.spiral didSelectIndex:self.index];
        _selected = true;
    }
}

- (void)unhighlight {
    //_currentColor = FG_GREY;
    //circle.fillColor = _currentColor.CGColor;
    [label setBackgroundColor:[UIColor clearColor]];
}

@end
