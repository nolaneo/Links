//
//  AddBookViewController.h
//  Links
//
//  Created by Eoin Nolan on 14/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LibraryViewController;

@interface AddBookViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource>
@property NSString * text;
@property (unsafe_unretained) LibraryViewController * parent;
@property IBOutlet UITextField * bookTitle;
- (void)setBookText:(NSString *)text;
@end
