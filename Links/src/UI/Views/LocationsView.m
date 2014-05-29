//
//  LocationsView.m
//  Links
//
//  Created by Eoin Nolan on 30/04/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "LocationsView.h"
#import "Book.h"
#import "Definitions.h"

@interface LocationsView ()
@property NSArray * edgesLocations;
@property NSArray * nodeLocations;
@end

@implementation LocationsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.edge != nil) {
        [self drawEdgeLocations:rect context:context];
    } else {
        [self drawNodeLocations:rect context:context];
    }

}

- (void)drawNodeLocations:(CGRect)rect context:(CGContextRef)context {
    float totalLength = self.node.book.text.length;
    CGContextBeginPath (context);
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetStrokeColorWithColor(context, STROKE_BLUE.CGColor);
    _nodeLocations = self.node.positions;
    for (int i = 0; i < _nodeLocations.count; i+=2) {
        NSNumber * position = [_nodeLocations objectAtIndex:i];
        float percentage = [position floatValue] / totalLength;
        
        float y = rect.size.height * percentage;
        
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, rect.size.width, y);
    }
    CGContextStrokePath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokeRect(context, rect);
}

- (void)drawEdgeLocations:(CGRect)rect context:(CGContextRef)context {
    float totalLength = self.node.book.text.length;
    CGContextBeginPath (context);
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetStrokeColorWithColor(context, STROKE_RED.CGColor);
    _edgesLocations = [self.edge getEdgeLocations];
    for (NSNumber * position in _edgesLocations) {
        float percentage = [position floatValue] / totalLength;
        
        float y = rect.size.height * percentage;
        
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, rect.size.width, y);
    }
    CGContextStrokePath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokeRect(context, rect);
}

- (NSUInteger)findClosestLocation:(NSUInteger)location {
    NSArray * locations;
    if (self.edge != nil) {
        locations = _edgesLocations;
    } else {
        locations = _nodeLocations;
    }
    NSUInteger closest = INT_MAX;
    NSUInteger result = 0;
    for (NSNumber * loc in locations) {
        NSLog(@"loc : %d, vs %d", [loc integerValue], location);
        if (abs([loc integerValue] - location) < closest) {
            closest = abs([loc integerValue] - location);
            result = [loc integerValue];
        }
    }
    return result;
}

@end
