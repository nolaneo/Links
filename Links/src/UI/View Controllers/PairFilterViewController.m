//
//  PairFilterViewController.m
//  Links
//
//  Created by Eoin Nolan on 11/05/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "PairFilterViewController.h"
#import "Node.h"
#import "FilterCell.h"

@interface PairFilterViewController ()
@property UITapGestureRecognizer * tapBehindGesture;
@property UIImage * tick_on;
@property UIImage * tick_off;
@end

@implementation PairFilterViewController

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

    _tick_on = [UIImage imageNamed:@"tick_on.png"];
    _tick_off = [UIImage imageNamed:@"tick_off.png"];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setupTapRecognizer];
}

- (void)setupTapRecognizer {
    _tapBehindGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    [_tapBehindGesture setNumberOfTapsRequired:1];
    _tapBehindGesture.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:_tapBehindGesture];
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            // Remove the recognizer first so it's view.window is valid.
            [self.view.window removeGestureRecognizer:sender];
            _tapBehindGesture = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
- (IBAction)save:(id)sender {
    [self.delegate applyFilters:self.lexicalCategories];
    [self.view.window removeGestureRecognizer:_tapBehindGesture];
    _tapBehindGesture = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCell * filterCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FilterCell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            [filterCell.textLabel setText:@"Show Nouns"];
            [filterCell.accessoryImageView setImage:([_lexicalCategories containsObject:@(NOUN)]) ? _tick_on : _tick_off];
            break;
        case 1:
            [filterCell.textLabel setText:@"Show Proper Nouns"];
            [filterCell.accessoryImageView setImage:([_lexicalCategories containsObject:@(PROPERNOUN)]) ? _tick_on : _tick_off];
            break;
        case 2:
            [filterCell.textLabel setText:@"Show Verbs"];
            [filterCell.accessoryImageView setImage:([_lexicalCategories containsObject:@(VERB)]) ? _tick_on : _tick_off];
            break;
        case 3:
            [filterCell.textLabel setText:@"Show Adverbs"];
            [filterCell.accessoryImageView setImage:([_lexicalCategories containsObject:@(ADVERB)]) ? _tick_on : _tick_off];
            break;
        case 4:
            [filterCell.textLabel setText:@"Show Adjectives"];
            [filterCell.accessoryImageView setImage:([_lexicalCategories containsObject:@(ADJECTIVE)]) ? _tick_on : _tick_off];
            break;
        case 5:
            [filterCell.textLabel setText:@"Show Idioms"];
            [filterCell.accessoryImageView setImage:([_lexicalCategories containsObject:@(IDIOM)]) ? _tick_on : _tick_off];
            break;
        case 6:
            [filterCell.textLabel setText:@"Show Classifiers"];
            [filterCell.accessoryImageView setImage:([_lexicalCategories containsObject:@(CLASSIFIER)]) ? _tick_on : _tick_off];
            break;
    }
    return filterCell;
}
#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Filter Selection : %d", indexPath.row);
    
    switch (indexPath.row) {
        case 0:
            [self changeLexicalSelection:NOUN];
            break;
        case 1:
            [self changeLexicalSelection:PROPERNOUN];
            break;
        case 2:
            [self changeLexicalSelection:VERB];
            break;
        case 3:
            [self changeLexicalSelection:ADVERB];
            break;
        case 4:
            [self changeLexicalSelection:ADJECTIVE];
            break;
        case 5:
            [self changeLexicalSelection:IDIOM];
            break;
        case 6:
            [self changeLexicalSelection:CLASSIFIER];
            break;
    }
    
    [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void)changeLexicalSelection:(WordType)wordtype {
    if ([self.lexicalCategories containsObject:@(wordtype)]) {
        [self.lexicalCategories removeObject:@(wordtype)];
    } else {
        [self.lexicalCategories addObject:@(wordtype)];
    }
}
@end
