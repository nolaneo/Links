//
//  AnnotationCell.m
//  Links
//
//  Created by Eoin Nolan on 06/05/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "AnnotationCell.h"


@implementation AnnotationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
