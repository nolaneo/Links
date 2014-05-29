//
//  UIBezierPath+Smoothing.h
//  Links
//  Thanks to Joshua Weinberg
//  Created by Eoin Nolan on 27/04/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (Smoothing)
- (UIBezierPath*)smoothedPathWithGranularity:(NSInteger)granularity;
@end
