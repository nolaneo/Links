//
//  LocationsView.h
//  Links
//
//  Created by Eoin Nolan on 30/04/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"
#import "Edge.h"
@interface LocationsView : UIView
@property Node * node;
@property Edge * edge;

- (NSUInteger)findClosestLocation:(NSUInteger)location;

@end
