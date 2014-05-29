//
//  WordTableViewCell.h
//  Links
//
//  Created by Eoin Nolan on 05/03/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordTableViewCell : UITableViewCell
@property IBOutlet UILabel * word;
@property IBOutlet UILabel * frequency;
@property IBOutlet UILabel * lexicalClass;
@property IBOutlet UIView * colorTagView;
@end
