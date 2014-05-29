//
//  WordTableViewController.m
//  Links
//
//  Created by Eoin Nolan on 05/03/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "WordTableViewController.h"
#import "Node.h"
#import "Book.h"
#import "BookInfo.h"
#import "WordToken.h"
#import "WordTableViewCell.h"
#import "BookCollection.h"
#import "Definitions.h"
#import "Library.h"
#import "Annotation.h"

#import "VisualisationTabBarController.h"
#import "UserFilterViewController.h"
#import "WordDetailViewController.h"



@interface WordTableViewController ()
@property NSArray * nodeArray;
@property UIBarButtonItem * filter;
@property Node * selectedNode;
@property IBOutlet UILabel * noResultsLabel;
@property NSNumber * setKey;
@end

@implementation WordTableViewController
@synthesize filter;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setBackgroundColor:BG_GREY];
    VisualisationTabBarController * parent = (VisualisationTabBarController *)[self tabBarController];
    _collection = parent.collection;
    //[self setupNavigationBar];
    _setKey = [Annotation getKey:self.collection.retainSet];
    [self reloadData];
}

- (void)setupNavigationBar {
    

    filter = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-filter"] style:UIBarButtonItemStylePlain target:self action:@selector(setFilters:)];
    
    self.navigationItem.rightBarButtonItem = filter;
}

- (void)setFilters:(id)sender {
    [self performSegueWithIdentifier:@"SetWordFiltersSegue" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"WordDetailSegue"]) {
        WordDetailViewController * wdvc = [segue destinationViewController];
        wdvc.node = _selectedNode;
        wdvc.collection = self.collection;
    }
}

- (void)reloadData {
    if (self.collection.lastResults == nil) {
        [self.collection applyFilters];
    }
    _nodeArray = self.collection.lastResults;
    [_noResultsLabel setHidden:!(_nodeArray.count == 0)];
    _setKey = [Annotation getKey:self.collection.retainSet];
    [self.tableView reloadData];
}

- (void)searchText {
    _nodeArray = [self.collection applySearch];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [_nodeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"WordTableViewCell";
    WordTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Node * node = [_nodeArray objectAtIndex:indexPath.row];
    [cell.word setText:node.word];
    
    Annotation * annotation = [Library annotationsForNode:@(node.key) setKey:_setKey];
    
    if (annotation != nil) {
        [cell.word setTextColor:UIColorFromRGB(0xf0bd8b)];
    } else {
        [cell.word setTextColor:[UIColor whiteColor]];
    }
    
    if (self.collection.proportionalSubtraction) {
        [cell.frequency setText:[NSString stringWithFormat:@"%.06f", node.proportional]];
    } else {
        [cell.frequency setText:[NSString stringWithFormat:@"%d", node.frequency]];
    }
    [cell.lexicalClass setText:[WordToken wordTypeToString:node.wordType]];
    [cell.colorTagView setBackgroundColor:[WordToken wordTypeToColor:node.wordType]];
    return cell; 
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedNode = [_nodeArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"WordDetailSegue" sender:self];
}
@end
