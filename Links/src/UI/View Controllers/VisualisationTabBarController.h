//
//  VisualisationTabBarController.h
//  Links
//
//  Created by Eoin Nolan on 19/03/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCollection.h"
@interface VisualisationTabBarController : UITabBarController <UISearchBarDelegate>
@property BookCollection * collection;
- (void)reloadData;
@end
