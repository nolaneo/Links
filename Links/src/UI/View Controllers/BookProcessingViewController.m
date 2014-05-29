//
//  BookProcessingViewController.m
//  Links
//
//  Created by Eoin Nolan on 05/03/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "BookProcessingViewController.h"
#import "BookInfo.h"
#import "Book.h"
#import "Node.h"
#import "Library.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ImageEffects.h"

@interface BookProcessingViewController ()
@property IBOutlet UILabel * statusLabel;
@property IBOutlet UIProgressView * progressView;
@property IBOutlet UIActivityIndicatorView * indicatorView;
@property IBOutlet UILabel * bookTitle;
@property IBOutlet UILabel * bookAuthor;
@property IBOutlet UIImageView * bookCover;

@property IBOutlet UILabel * nounsTotal;
@property IBOutlet UILabel * properNounsTotal;
@property IBOutlet UILabel * verbsTotal;
@property IBOutlet UILabel * adverbsTotal;
@property IBOutlet UILabel * adjectivesTotal;
@property IBOutlet UILabel * classifiersTotal;
@property IBOutlet UILabel * idiomsTotal;
@property IBOutlet UILabel * wordTotal;

@property IBOutlet UILabel * nodesTotal;
@property IBOutlet UILabel * edgesTotal;
@end

@implementation BookProcessingViewController
@synthesize progressView, statusLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_indicatorView stopAnimating];
    if (self.bookInfo.imageURL != nil) {
        NSURL *url = [NSURL URLWithString:self.bookInfo.imageURL];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
        UIImage * dark = [img applyBlurWithRadius:5 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
        [_bookCover setImage:dark];
    }
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self beginProcessing];
}

- (void)beginProcessing {
    
    [_bookTitle  setText:self.bookInfo.title];
    [_bookAuthor setText:self.bookInfo.author];
    //  [_bookCover setImageWithURL:[NSURL URLWithString:self.bookInfo.imageURL] placeholderImage:[UIImage imageNamed:@"no-cover-image.png"]];
    
    Book * book = [Book bookWithInfo:self.bookInfo];
    [book setDelegate:self];
    
    [book performSelectorInBackground:@selector(processBookWithCompletion:) withObject:^(NSString *result) {
        NSLog(@"Book fully processed");
        [Library addBookInfo:self.bookInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_indicatorView startAnimating];
            [statusLabel setText:@"Saving to disk"];
        });
        [book save];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        });
        
    }];
}
    

#pragma BookProcessingDelegate
- (void)updateTokenizationProgress:(NSNumber *)progress {
    [progressView setProgress:[progress floatValue]];
}
- (void)updateGraphCreationProgress:(NSNumber *)progress {
    [progressView setProgress:[progress floatValue]];
}
- (void)updateStatusLabel:(NSString *)status {
    [statusLabel setText:status];
}
- (void)updateWordProcessingTotalNouns:(NSUInteger)nouns verbs:(NSUInteger)verbs adjectives:(NSUInteger)adjectives {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_nounsTotal setText:[NSString stringWithFormat:@"%d", nouns]];
        [_verbsTotal setText:[NSString stringWithFormat:@"%d", verbs]];
        [_adjectivesTotal setText:[NSString stringWithFormat:@"%d", adjectives]];
        [_wordTotal setText:[NSString stringWithFormat:@"%d", nouns+verbs+adjectives]];
    });
}
- (void)updateGraphProcessingWithNodes:(NSUInteger)nodes edges:(NSUInteger)edges {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_nodesTotal setText:[NSString stringWithFormat:@"%d", nodes]];
        [_edgesTotal setText:[NSString stringWithFormat:@"%d", edges]];
    });
}

- (void)updateWordProcessingTotal:(struct ProcessingUpdate)update {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_nounsTotal setText:[NSString stringWithFormat:@"%d", update.nouns]];
        [_verbsTotal setText:[NSString stringWithFormat:@"%d", update.verbs]];
        [_adjectivesTotal setText:[NSString stringWithFormat:@"%d", update.adjectives]];
        [_properNounsTotal setText:[NSString stringWithFormat:@"%d", update.propernouns]];
        [_adverbsTotal setText:[NSString stringWithFormat:@"%d", update.adverbs]];
        [_classifiersTotal setText:[NSString stringWithFormat:@"%d", update.classifiers]];
        [_idiomsTotal setText:[NSString stringWithFormat:@"%d", update.idioms]];
        [_wordTotal setText:[NSString stringWithFormat:@"%d", update.nouns+update.verbs+update.adjectives+update.adverbs+update.classifiers+update.idioms+update.propernouns]];
    });
}

@end
