//
//  BookViewController.h
//  Links
//
//  Created by Eoin Nolan on 01/05/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
@interface BookViewController : UIViewController
@property Book * book;
@property NSUInteger scrollPosition;
@property NSRange range;
- (void)scrollToPosition:(NSUInteger)position;
@end
