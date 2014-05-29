//
//  CopyLabel.m
//  Links
//
//  Created by Eoin Nolan on 21/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "CopyLabel.h"
#import "AddBookViewController.h"
@interface CopyLabel ()
- (void) unhilight;
@end
@implementation CopyLabel

#pragma mark Initialization

- (void) attachTapHandler
{
    [self setUserInteractionEnabled:YES];
    UIGestureRecognizer *touchy = [[UILongPressGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:touchy];
}

- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isSet = false;
        [self attachTapHandler];
        
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isSet = false;
        [self attachTapHandler];
    }
    return self;
}

- (void)setTarget:(id)target forCopyAction:(SEL)action{
    copyTarget = target;
    copyAction = action;
}

- (void)setTarget:(id)target forPasteAction:(SEL)action {
    copyTarget = target;
    copyAction = action;
}

#pragma mark Clipboard

- (void) paste: (id) sender
{
    self.isSet = true;
    [self.parent setBookText:[[UIPasteboard generalPasteboard] string]];
}

- (void) unhilight{
    self.highlighted = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
}
- (BOOL) canPerformAction: (SEL) action withSender: (id) sender
{
    return (action == @selector(paste:));
}

- (void) handleTap: (UIGestureRecognizer*) recognizer
{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (![menu isMenuVisible]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhilight) name:UIMenuControllerWillHideMenuNotification object:nil];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
        self.highlighted = YES;
    }
    
}

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

@end

