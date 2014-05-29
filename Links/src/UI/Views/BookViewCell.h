//
//  BookViewCell.h
//  Links
//
//  Created by Eoin Nolan on 18/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookViewCell : UICollectionViewCell
@property IBOutlet UILabel * title;
@property IBOutlet UILabel * author;
@property IBOutlet UIImageView * cover;
@property IBOutlet UILabel * wordCount;
@property IBOutlet UILabel * pairCount;
@property IBOutlet UIButton * sentimentButton;
@property IBOutlet UIButton * annotationsButton;

- (void)setCoverImage:(NSString *)url;
- (void)setTitleText:(NSString *)title;
- (void)setAuthorText:(NSString *)author;
@end
