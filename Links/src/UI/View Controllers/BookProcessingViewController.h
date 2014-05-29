//
//  BookProcessingViewController.h
//  Links
//
//  Created by Eoin Nolan on 05/03/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
@interface BookProcessingViewController : UIViewController <BookProcessingDelegate>
@property BookInfo * bookInfo;
@end
