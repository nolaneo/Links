//
//  UINavigationController+RotationFix.m
//  Links
//
//  Created by Eoin Nolan on 28/04/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "UINavigationController+RotationFix.h"

@implementation UINavigationController (RotationFix)

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end