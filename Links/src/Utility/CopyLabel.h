//
//  CopyLabel.h
//  Links
//
//  Created by Eoin Nolan on 21/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AddBookViewController;
@interface CopyLabel : UILabel {
    SEL copyAction;
    id copyTarget;
}
@property BOOL isSet;
@property (unsafe_unretained) AddBookViewController * parent;
- (void)setTarget:(id)target forCopyAction:(SEL)action;
- (void)setTarget:(id)target forPasteAction:(SEL)action;
@end