//
//  AnnotationCell.h
//  Links
//
//  Created by Eoin Nolan on 06/05/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnotationCell : UITableViewCell
@property IBOutlet UIImageView * image;
@property IBOutlet UILabel * type;
@property IBOutlet UILabel * name;
@property IBOutlet UITextView * text;
@property IBOutlet UITextView * books;
@end
