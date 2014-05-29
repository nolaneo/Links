//
//  BookViewCell.m
//  Links
//
//  Created by Eoin Nolan on 18/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "BookViewCell.h"
#import "Definitions.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@implementation BookViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDesign];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDesign];
    }
    return self;
}

- (void)setupDesign {
    
    self.layer.masksToBounds = NO;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = UI_LIGHT_GREY.CGColor;
    self.cover.layer.borderWidth = 1.0f;
    self.cover.layer.borderColor = UI_LIGHT_GREY.CGColor;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, 200)];
    [path addLineToPoint:CGPointMake(369, 200)];
    [path addLineToPoint:CGPointMake(369, 202)];
    [path addLineToPoint:CGPointMake(0, 202)];

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.fillColor = [UI_LIGHT_GREY CGColor];
    
    [self.layer addSublayer:shapeLayer];
}

- (void)setTitleText:(NSString *)title {
    [self.title setText:title];
}
- (void)setAuthorText:(NSString *)author {
    [self.author setText:author];
}

- (void)setCoverImage:(NSString *)url {
    [self.cover setBackgroundColor:UI_BLUE];
    [self.cover setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"no-cover-image.png"]];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        [UIView animateWithDuration:0.1f animations:^{
            self.backgroundColor = UI_HIGHLIGHT_BLUE;
        }];
    } else {
        [UIView animateWithDuration:0.1f animations:^{
            self.backgroundColor = [UIColor whiteColor];
        }];
    }
}

@end
