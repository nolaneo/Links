//
//  UserFilterViewController.m
//  Links
//
//  Created by Eoin Nolan on 12/03/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "UserFilterViewController.h"
#import "UIImageView+WebCache.h"
#import "SearchResultCell.h"
#import "Book.h"
#import "BookInfo.h"
#import "Node.h"
#import "FilterCell.h"

@interface UserFilterViewController ()
@property UITapGestureRecognizer * tapBehindGesture;
@property IBOutlet UISwitch * nounSwitch;
@property IBOutlet UISwitch * verbSwitch;
@property IBOutlet UISwitch * adjectiveSwitch;
@property IBOutlet UISwitch * ascendingSwtich;
@property IBOutlet UISwitch * proportionalSwitch;
@property IBOutlet DragAndDropTableView * tableView;
@property NSMutableArray * dataSource;

@property UIImage * tick_on;
@property UIImage * tick_off;

@end

@implementation UserFilterViewController

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
    [self setupSwitches];
    NSMutableArray * retainBooks  = [NSMutableArray arrayWithArray:[self.collection.retainSet allObjects]];
    NSMutableArray * discardBooks = [NSMutableArray arrayWithArray:[self.collection.discardSet allObjects]];
    _dataSource = [NSMutableArray arrayWithObjects:retainBooks, discardBooks, nil];
    
    _tick_on = [UIImage imageNamed:@"tick_on.png"];
    _tick_off = [UIImage imageNamed:@"tick_off.png"];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)setupSwitches {
    if (self.collection.lexicalClasses == nil) {
        [_nounSwitch setOn:YES];
        [_verbSwitch setOn:YES];
        [_adjectiveSwitch setOn:YES];
    } else {
        [_nounSwitch setOn:[self.collection.lexicalClasses containsObject:@(NOUN)]];
        [_verbSwitch setOn:[self.collection.lexicalClasses containsObject:@(VERB)]];
        [_adjectiveSwitch setOn:[self.collection.lexicalClasses containsObject:@(ADJECTIVE)]];
    }

    [_ascendingSwtich setOn:self.collection.ascending];
    [_proportionalSwitch setOn:self.collection.proportionalSubtraction];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)applyFilters:(id)sender {
    [self.view.window removeGestureRecognizer:_tapBehindGesture];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.parent reloadData];
    }];
}

- (IBAction)switchChange:(id)sender {
    if (sender == _nounSwitch || sender == _verbSwitch || sender == _adjectiveSwitch) {
        [self handleLexicalSwitch];
        return;
    }
    self.collection.ascending = [_ascendingSwtich isOn];
    self.collection.proportionalSubtraction = [_proportionalSwitch isOn];
}

- (void)handleLexicalSwitch {
    
    if ([_nounSwitch isOn] && [_verbSwitch isOn] && [_adjectiveSwitch isOn]) {
        self.collection.lexicalClasses = nil;
        return;
    } else {
        self.collection.lexicalClasses = [NSMutableSet set];
    }
    
    if ([_nounSwitch isOn]) {
        [self.collection.lexicalClasses addObject:@(NOUN)];
    } else {
        [self.collection.lexicalClasses removeObject:@(NOUN)];
    }
    if ([_verbSwitch isOn]) {
        [self.collection.lexicalClasses addObject:@(VERB)];
    } else {
        [self.collection.lexicalClasses removeObject:@(VERB)];
    }
    if ([_adjectiveSwitch isOn]) {
        [self.collection.lexicalClasses addObject:@(ADJECTIVE)];
    } else {
        [self.collection.lexicalClasses removeObject:@(ADJECTIVE)];
    }
    
}

#pragma mark -

#pragma mark UITableViewDataSource

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataSource objectAtIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableViewCellName = @"SearchResultCell";
    
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellName];
    BookInfo * info = [[[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] bookInfo];
    [cell.authorLabel setText:info.author];
    [cell.titleLabel setText:info.title];
    [cell.coverImageView setImageWithURL:[NSURL URLWithString:info.imageURL] placeholderImage:[UIImage imageNamed:@"no-cover-image.png"]];
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Book *o = [[_dataSource objectAtIndex:sourceIndexPath.section] objectAtIndex:sourceIndexPath.row];
    [[_dataSource objectAtIndex:sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
    [[_dataSource objectAtIndex:destinationIndexPath.section] insertObject:o atIndex:destinationIndexPath.row];
    
    if (destinationIndexPath.section == 0) {
        [self.collection.retainSet addObject:o];
        [self.collection.discardSet removeObject:o];
    } else {
        [self.collection.discardSet addObject:o];
        [self.collection.retainSet removeObject:o];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(UITableViewCellEditingStyleInsert == editingStyle)
    {
        // inserts are always done at the end
        
        [tableView beginUpdates];
        [_dataSource addObject:[NSMutableArray array]];
        [tableView insertSections:[NSIndexSet indexSetWithIndex:[_dataSource count]-1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        
    }
    else if(UITableViewCellEditingStyleDelete == editingStyle)
    {
        // check if we are going to delete a row or a section
        [tableView beginUpdates];
        if([[_dataSource objectAtIndex:indexPath.section] count] == 0)
        {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_dataSource removeObjectAtIndex:indexPath.section];
        }
        else
        {
            // Delete the row from the table view.
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            // Delete the row from the data source.
            [[_dataSource objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        }
        [tableView endUpdates];
    }
}

#pragma mark -

#pragma mark UITableViewDelegate

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"Show words from these books" : @"Hide words from these books";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

#pragma mark -

#pragma mark DragAndDropTableViewDataSource

-(BOOL)canCreateNewSection:(NSInteger)section
{
    return YES;
}

#pragma mark -

#pragma mark DragAndDropTableViewDelegate

-(void)tableView:(UITableView *)tableView willBeginDraggingCellAtIndexPath:(NSIndexPath *)indexPath placeholderImageView:(UIImageView *)placeHolderImageView
{
    // this is the place to edit the snapshot of the moving cell
    // add a shadow
    placeHolderImageView.layer.shadowOpacity = .3;
    placeHolderImageView.layer.shadowRadius = 1;
    
    
}

-(void)tableView:(DragAndDropTableView *)tableView didEndDraggingCellToIndexPath:(NSIndexPath *)indexPath placeHolderView:(UIImageView *)placeholderImageView
{
    // The cell has been dropped. Remove all empty sections (if you want to)
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for(int i = 0; i < _dataSource.count; i++)
    {
        NSArray *ary = [_dataSource objectAtIndex:i];
        if(ary.count == 0)
            [indexSet addIndex:i];
    }
    
    [tableView beginUpdates];
    [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    [_dataSource removeObjectsAtIndexes:indexSet];
    [tableView endUpdates];
}

-(CGFloat)tableView:tableView heightForEmptySection:(int)section
{
    return 10;
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCell * filterCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FilterCell" forIndexPath:indexPath];

    switch (indexPath.row) {
        case 0:
            [filterCell.textLabel setText:@"Show Nouns"];
            [filterCell.accessoryImageView setImage:([self.collection.lexicalClasses containsObject:@(NOUN)]) ? _tick_on : _tick_off];
            break;
        case 1:
            [filterCell.textLabel setText:@"Show Proper Nouns"];
            [filterCell.accessoryImageView setImage:([self.collection.lexicalClasses containsObject:@(PROPERNOUN)]) ? _tick_on : _tick_off];
            break;
        case 2:
            [filterCell.textLabel setText:@"Show Verbs"];
            [filterCell.accessoryImageView setImage:([self.collection.lexicalClasses containsObject:@(VERB)]) ? _tick_on : _tick_off];
            break;
        case 3:
            [filterCell.textLabel setText:@"Show Adverbs"];
            [filterCell.accessoryImageView setImage:([self.collection.lexicalClasses containsObject:@(ADVERB)]) ? _tick_on : _tick_off];
            break;
        case 4:
            [filterCell.textLabel setText:@"Show Adjectives"];
            [filterCell.accessoryImageView setImage:([self.collection.lexicalClasses containsObject:@(ADJECTIVE)]) ? _tick_on : _tick_off];
            break;
        case 5:
            [filterCell.textLabel setText:@"Show Idioms"];
            [filterCell.accessoryImageView setImage:([self.collection.lexicalClasses containsObject:@(IDIOM)]) ? _tick_on : _tick_off];
            break;
        case 6:
            [filterCell.textLabel setText:@"Show Classifiers"];
            [filterCell.accessoryImageView setImage:([self.collection.lexicalClasses containsObject:@(CLASSIFIER)]) ? _tick_on : _tick_off];
            break;
        case 7:
            [filterCell.textLabel setText:@"Sort ascending"];
            [filterCell.accessoryImageView setImage:(self.collection.ascending) ? _tick_on : _tick_off];
            break;
        case 8:
            [filterCell.textLabel setText:@"Only show common words"];
            [filterCell.accessoryImageView setImage:(self.collection.join) ? _tick_on : _tick_off];
            break;
        case 9:
            [filterCell.textLabel setText:@"Subtract proportionally"];
            [filterCell.accessoryImageView setImage:(self.collection.proportionalSubtraction) ? _tick_on : _tick_off];
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
        case 7:
            self.collection.ascending = !self.collection.ascending;
            break;
        case 8:
            self.collection.join = !self.collection.join;
            break;
        case 9:
            self.collection.proportionalSubtraction = !self.collection.proportionalSubtraction;
            break;
    }

    [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void)changeLexicalSelection:(WordType)wordtype {
    if ([self.collection.lexicalClasses containsObject:@(wordtype)]) {
        [self.collection.lexicalClasses removeObject:@(wordtype)];
    } else {
        [self.collection.lexicalClasses addObject:@(wordtype)];
    }
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0, 0, 540, 660);
}

@end
