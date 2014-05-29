//
//  UISpiralView.m
//  Links
//
//  Created by Eoin Nolan on 18/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import <math.h>
#import "UISpiralView.h"
#import "CircleView.h"
#include "Definitions.h"

#define MAX_SPIRAL_ELEMENTS 500

@interface UISpiralView ()
@property double x;
@property double y;
@property double centerX;
@property double centerY;
@property NSUInteger count;
@property CGFloat lastScale;
@end

@implementation UISpiralView

@synthesize x, y, count, centerX, centerY, baseView, spiralVertices, lastScale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSpiral];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSpiral];
    }
    return self;
}

- (void)initSpiral {
    spiralVertices = [NSMutableArray array];
    baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXSIZE, MAXSIZE)];
    [baseView setBackgroundColor:[UIColor yellowColor]];
    [super addSubview:baseView];
    [baseView setBackgroundColor:BG_GREY];
    [self setBackgroundColor:BG_GREY];
    x = MAXSIZE/2;
    y = MAXSIZE/2;
    centerX = MAXSIZE/2;
    centerY = MAXSIZE/2;
    count = 0;
    lastScale = -1;
}

- (void)setContentOffset:(CGPoint)anOffset {
	if(baseView != nil) {
		CGSize zoomViewSize = baseView.frame.size;
		CGSize scrollViewSize = self.bounds.size;
		
		if(zoomViewSize.width < scrollViewSize.width) {
			anOffset.x = -(scrollViewSize.width - zoomViewSize.width) / 2.0;
		}
		
		if(zoomViewSize.height < scrollViewSize.height) {
			anOffset.y = -(scrollViewSize.height - zoomViewSize.height) / 2.0;
		}
	}
	
	super.contentOffset = anOffset;
}

- (void)saveVertex:(SpiralVertex)vertex {
    // To add your struct value to a NSMutableArray
    NSValue * value = [NSValue valueWithBytes:&vertex objCType:@encode(SpiralVertex)];
    [spiralVertices addObject:value];
}

- (SpiralVertex)getVertex:(NSInteger)index {
    SpiralVertex structValue;
    NSValue * value = [spiralVertices objectAtIndex:index];
    [value getValue:&structValue];
    return structValue;
}

- (void)renderVisibleSubviewAtScale:(CGFloat)scale x:(CGFloat)screenX y:(CGFloat)screenY shouldRedraw:(BOOL)redraw {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //NSLog(@"SCALE = %f, X = %f, Y = %f, SW = %f, SH = %f", scale, screenX, screenY, screenWidth, screenHeight);
    
    for (int i = 0; i < [spiralVertices count]; ++i) {
        SpiralVertex vtx = [self getVertex:i];
        CGFloat vertexX = vtx.x * scale;
        CGFloat vertexY = vtx.y * scale;
        //NSLog(@"VTX x = %d, y = %d", vtx.x, vtx.y);
        UIView * subview = [[self.baseView subviews] objectAtIndex:i];
        
        if (vertexX >= screenX && vertexX <= screenX + screenWidth
            && vertexY >= screenY && vertexY <= screenY + screenHeight) {
            
            if (vtx.w * scale < 20) {
                [subview setHidden:YES];
                continue;
            } else {
                [subview setHidden:NO];
            }
            if (redraw) {
                [subview setContentScaleFactor:scale];
                for (UIView * view in subview.subviews) {
                    [view setContentScaleFactor:scale];
                }
            }

        } else {
            [subview setHidden:YES];
        }
    }
    lastScale = scale;
}

- (void)reloadData {
    for (CircleView * view in [baseView subviews]) {
        [view removeFromSuperview];
    }
    [spiralVertices removeAllObjects];
    double maxFrequency = [self.delegate getMaxFrequency];
    
    SpiralVertex sv;
    sv.x = centerX;
    sv.y = centerY;
    sv.w = MAX_CIRCLE_WIDTH;
    [self saveVertex:sv];
    
    double theta = 0;
    
    double maxDistance = 0;
    double bufferDistance = 0;
    
    if ([self.delegate numberOfViewsInSpiral] > 0) {
        maxDistance = (([self.delegate getFrequencyForIndex:1] / maxFrequency) * MAX_CIRCLE_WIDTH) / 2 + MAX_CIRCLE_WIDTH/2 + 20;
        bufferDistance = (([self.delegate getFrequencyForIndex:1] / maxFrequency) * MAX_CIRCLE_WIDTH);
        CircleView * view = (CircleView *)[self.delegate subViewForIndex:0];
        view.spiral = self;
        view.center = CGPointMake(centerX, centerY);
        [baseView addSubview:view];
    }
    int rotations = 1;
    double lastPoint = 0;
    for (int i = 1; i < [self.delegate numberOfViewsInSpiral] && i < MAX_SPIRAL_ELEMENTS; ++i) {
        double currentPointWidth = ([self.delegate getFrequencyForIndex:i] / maxFrequency) * MAX_CIRCLE_WIDTH;

        theta += (lastPoint/2 + currentPointWidth/2) / ( (maxDistance + bufferDistance * fmod(theta, 1)) * 2 * M_PI);
        
        if (theta >= rotations) {
            rotations++;
            maxDistance += bufferDistance;
            bufferDistance = currentPointWidth;
        }
        
        lastPoint = currentPointWidth;
        x = centerX + (maxDistance + bufferDistance * fmod(theta, 1)) * cos(2 * M_PI * theta);
        y = centerY + (maxDistance + bufferDistance * fmod(theta, 1)) * sin(2 * M_PI * theta);
        //NSLog(@"THETA : %f -- %f, %f : CurrentPointWidth = %2f", theta, x-centerX, y-centerY, currentPointWidth);
        CircleView * view = (CircleView *)[self.delegate subViewForIndex:i];
        view.center = CGPointMake(x, y);
        view.spiral = self;
        [view setHidden:NO];
        [self.baseView addSubview:view];
        SpiralVertex sv;
        sv.x = x;
        sv.y = y;
        sv.w = view.frame.size.width;
        [self saveVertex:sv];
        

    }
    if ([self.delegate numberOfViewsInSpiral] > 0) {
        [self renderVisibleSubviewAtScale:self.zoomScale x:self.contentOffset.x * self.zoomScale y:self.contentOffset.y * self.zoomScale shouldRedraw:YES];
    }
    
}

-(void)drawRect:(CGRect)rect {
    NSLog(@"Draw X %f, Y %f, W %f, H %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)didSelectIndex:(NSUInteger)index {
    [self.delegate didSelectViewAtIndex:index];
}

- (void)didDeselectIndex:(NSUInteger)index {
    [self.delegate didDeselectViewAtIndex:index];
}

- (void)highlightViewAtIndex:(NSUInteger)index weight:(float)weight{
    NSLog(@"Highlight object at index %d, weight = %f", index, weight);
    NSArray * subviews = [baseView subviews];
    CircleView * view = (CircleView *)[subviews objectAtIndex:index];
    [view highlight:YES weight:weight];
    
}

- (void)unhighlightAll {
    for (CircleView * view in [baseView subviews]) {
        [view unhighlight];
    }
}

@end
