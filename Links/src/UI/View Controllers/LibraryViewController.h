//
//  BooksViewController.h
//  Links
//
//  Created by Eoin Nolan on 18/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AnnotationsViewController.h"

@class BookInfo;

@interface LibraryViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, AnnotationProtocol>
- (void)saveAndProcessBookInfo:(BookInfo *)info;
- (void)addNewBookWithText:(NSString *)text title:(NSString *)title ;
@end
