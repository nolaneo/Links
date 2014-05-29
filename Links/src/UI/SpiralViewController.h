//
//  SpiralViewController.h
//  Links
//
//  Created by Eoin Nolan on 18/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UISpiralView.h"
#import "Book.h"
#import "BookCollection.h"
@interface SpiralViewController : UIViewController <UISpiralViewDelegate, UIScrollViewDelegate>
@property (nonatomic) IBOutlet UISpiralView * view;
@property Book * book;
@property BookCollection * collection;

- (void)reloadData;
@end
