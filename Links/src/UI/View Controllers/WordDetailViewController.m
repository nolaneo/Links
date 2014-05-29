//
//  WordDetailViewController.m
//  Links
//
//  Created by Eoin Nolan on 30/04/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "WordDetailViewController.h"
#import "Edge.h"
#import "Book.h"
#import "EdgeCell.h"
#import "EdgeList.h"
#import "Definitions.h"
#import "LocationsView.h"
#import "Library.h"
#import "Annotation.h"
#import "BookViewController.h"
#import "PairFilterViewController.h"
#import "WordToken.h"

@interface WordDetailViewController ()
@property IBOutlet UILabel * wordLabel;
@property IBOutlet UITableView * edgeTable;
@property NSArray * allEdges;
@property NSArray * edgeArray;
@property IBOutlet LocationsView * locationsView;

@property IBOutlet UIImageView * pairImage;
@property IBOutlet UILabel * pairLabel;
@property Edge * selectedEdge;
@property UITapGestureRecognizer * tapGesture;
@property NSNumber * setKey;
@property float touchLocation;

@property NSMutableSet * lexicalCategories;

@end

@implementation WordDetailViewController

static UIImage * arrowPlain, * arrowPlainStart, * arrowPlainEnd, * arrowAnnotated, * arrowAnnotatedStart, * arrowAnnotatedEnd;

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
    _setKey = [Annotation getKey:self.collection.retainSet];
    [self setupUI];
    _allEdges = [self.node getAllEdges];
    _lexicalCategories = [NSMutableSet setWithObjects:@(NOUN), @(PROPERNOUN), @(VERB), @(ADVERB), @(ADJECTIVE), @(IDIOM), @(CLASSIFIER), nil];
    [self applyFilters:_lexicalCategories];
    [_edgeTable reloadData];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [_locationsView removeGestureRecognizer:_tapGesture];
    _tapGesture = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openbook:)];
    [_locationsView addGestureRecognizer:_tapGesture];
    [_tapGesture setNumberOfTapsRequired:2];
}

- (void)setupUI {

    UIBarButtonItem * filter = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-filter"] style:UIBarButtonItemStylePlain target:self action:@selector(setFilters:)];
    
    self.navigationItem.rightBarButtonItem = filter;
    
    [_pairImage setHidden:YES];
    [_pairLabel setHidden:YES];
    _locationsView.node = self.node;
    [_wordLabel setText:self.node.word];
    [_wordLabel sizeToFit];
    CGRect frame = _wordLabel.frame;
    frame.size.height = 70;
    frame.size.width += 20;
    _wordLabel.frame = frame;
    [_edgeTable setBackgroundColor:BG_GREY];
    if (arrowPlain == nil) {
        arrowPlain = [UIImage imageNamed:@"arrow-plain.png"];
        arrowPlainStart = [UIImage imageNamed:@"arrow-plain-start.png"];
        arrowPlainEnd = [UIImage imageNamed:@"arrow-plain-end.png"];
        arrowAnnotated = [UIImage imageNamed:@"arrow-annotated.png"];
        arrowAnnotatedStart = [UIImage imageNamed:@"arrow-annotated-start.png"];
        arrowAnnotatedEnd = [UIImage imageNamed:@"arrow-annotated-end.png"];
    }
    [self setWordColor];
}


- (void)showEdge:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_edgeTable];
    NSIndexPath *indexPath = [_edgeTable indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        Edge * edge = [_edgeArray objectAtIndex:indexPath.row];
        [_pairImage setHidden:NO];
        [_pairLabel setText:[edge getAdjacentNodeTo:self.node].word];
        [_pairLabel setHidden:NO];
        _locationsView.edge = edge;
        [_locationsView setNeedsDisplay];
        _selectedEdge = edge;
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_edgeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"EdgeCell";
    EdgeCell * edgeCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Edge * edge = [_edgeArray objectAtIndex:indexPath.row];
    Node * node = [edge getAdjacentNodeTo:self.node];
    [edgeCell.wordLabel setText:node.word];
    [edgeCell.weightButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)edge.weight] forState:UIControlStateNormal];
    [edgeCell.weightButton setTitleColor:STROKE_BLUE forState:UIControlStateHighlighted];
    [edgeCell.weightButton addTarget:self action:@selector(showEdge:) forControlEvents:UIControlEventTouchUpInside];
    
    Annotation * annotation = [Library annotationsForEdge:[edge key] setKey:_setKey];
    if (annotation != nil) {
        [edgeCell.wordLabel setTextColor:UIColorFromRGB(0xf0bd8b)];
        if (indexPath.row == 0) {
            [edgeCell.arrowImage setImage:arrowAnnotatedStart];
        } else if (indexPath.row == _edgeArray.count - 1) {
            [edgeCell.arrowImage setImage:arrowAnnotatedEnd];
        } else {
            [edgeCell.arrowImage setImage:arrowAnnotated];
        }
    } else {
        [edgeCell.wordLabel setTextColor:[UIColor whiteColor]];
        if (indexPath.row == 0) {
            [edgeCell.arrowImage setImage:arrowPlainStart];
        } else if (indexPath.row == _edgeArray.count - 1) {
            [edgeCell.arrowImage setImage:arrowPlainEnd];
        } else {
            [edgeCell.arrowImage setImage:arrowPlain];
        }
    }
    
    [edgeCell.lexicalTypeView setBackgroundColor:[WordToken wordTypeToColor:node.wordType]];
    
    return edgeCell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"Selected row : %d", indexPath.row);
    UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    WordDetailViewController * wdvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"WordDetailViewController"];
    Edge * edge = [_edgeArray objectAtIndex:indexPath.row];
    Node * adjacentNode = [edge getAdjacentNodeTo:self.node];
    
    wdvc.node = adjacentNode;
    
    [self.navigationController pushViewController:wdvc animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AnnotateSegue"]) {
        AnnotationsViewController * avc = [segue destinationViewController];
        avc.books = self.collection.retainSet;
        avc.delegate = self;
        if (_selectedEdge != nil) {
            avc.edge = _selectedEdge;
        } else {
            avc.node = self.node;
        }
    } else
    if ([segue.identifier isEqualToString:@"OpenBookSegue"]) {
        BookViewController * bvc = [segue destinationViewController];
        bvc.book = self.node.book;
        
        NSUInteger location = [_locationsView findClosestLocation:(_touchLocation/_locationsView.frame.size.height) * (bvc.book.text.length)];
        NSLog(@"Location : %lu vs %f", (unsigned long)location, (_touchLocation/_locationsView.frame.size.height) * (bvc.book.text.length));
        [bvc setScrollPosition:location];
        
    } else
    if ([segue.identifier isEqualToString:@"PairFilterSegue"]) {
        PairFilterViewController * pfvc = [segue destinationViewController];
        pfvc.delegate = self;
        pfvc.lexicalCategories = _lexicalCategories;
    }
}

/* ------ IBACTIONS ------ */

- (IBAction)clearSelection:(id)sender {
    _locationsView.edge = nil;
    [_pairImage setHidden:YES];
    [_pairLabel setHidden:YES];
    [_locationsView setNeedsDisplay];
    _selectedEdge = nil;
}

- (IBAction)annotate:(id)sender {
    [self performSegueWithIdentifier:@"AnnotateSegue" sender:self];
}

#pragma mark AnnotationProtocol
- (void)reloadAnnotations {
    [_edgeTable reloadData];
    [self setWordColor];
}

- (void)setWordColor {
    Annotation * annotation = [Library annotationsForNode:@(self.node.key) setKey:_setKey];
    if (annotation != nil) {
        [_wordLabel setTextColor:UIColorFromRGB(0xf0bd8b)];
    }
}

- (void)openbook:(UITapGestureRecognizer *)sender {
    NSLog(@"Tapped");
    CGPoint point = [sender locationInView:_locationsView];
    NSLog(@"Touch at %f, %f", point.x, point.y);
    _touchLocation = point.y;
    [self performSegueWithIdentifier:@"OpenBookSegue" sender:self];
}

- (void)setFilters:(id)sender {
    [self performSegueWithIdentifier:@"PairFilterSegue" sender:self];
}

- (void)applyFilters:(NSMutableSet *)filters {
    _lexicalCategories = filters;
    NSMutableArray * array = [NSMutableArray array];
    for (Edge * e in _allEdges) {
        Node * n = [e getAdjacentNodeTo:self.node];
        if ([_lexicalCategories containsObject:@(n.wordType)]) {
            [array addObject:e];
        }
    }
    _edgeArray = array;
    [_edgeTable reloadData];
}

@end
