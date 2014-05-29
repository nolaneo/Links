//
//  BooksViewController.m
//  Links
//
//  Created by Eoin Nolan on 18/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "LibraryViewController.h"
#import "BookViewCell.h"
#import "Library.h"
#import "BookInfo.h"
#import "Node.h"
#import "Definitions.h"
#import "MBProgressHUD.h"

#import "AddBookViewController.h"
#import "BookProcessingViewController.h"
#import "VisualisationTabBarController.h"
#import "GraphViewController.h"
#import "AnnotationsViewController.h"

#import "BookCollection.h"

@interface LibraryViewController ()
@property IBOutlet UILabel * emptyLibrary;
@property UISearchBar * searchbar;
@property UIBarButtonItem * add;
@property UIBarButtonItem * filter;
@property UIBarButtonItem * process;
@property UIBarButtonItem * sentiment;
@property NSArray * bookInfoArray;
@property UITapGestureRecognizer * tapBehindGesture;

@property BookInfo * currentBookInfo;
@property BookInfo * annotationBookInfo;
@property BookCollection * currentCollection;
@property NSMutableSet * selectedBooks;

@property UITapGestureRecognizer * clearCache;
@end

@implementation LibraryViewController
@synthesize searchbar, add, filter, process, sentiment, bookInfoArray;
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
    _selectedBooks = [NSMutableSet set];
    [self.collectionView setAllowsMultipleSelection:YES];
    [self setupNavigationBar];
    _clearCache = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearLibCache)];
    [_clearCache setNumberOfTapsRequired:3];
    [self.view addGestureRecognizer:_clearCache];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidAppear:(BOOL)animated {
    [self reloadLibrary];
}

- (void)viewWillDisappear:(BOOL)animated {
    _tapBehindGesture = nil;
}

- (void)setupNavigationBar {
    
    searchbar = [[UISearchBar alloc] init];
    searchbar.placeholder = @"Search Library";
    searchbar.searchBarStyle = UISearchBarStyleMinimal;
    self.navigationItem.titleView = searchbar;
    
    add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewBook:)];
    filter = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-filter"] style:UIBarButtonItemStylePlain target:self action:@selector(setFilters:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:add, filter, nil];
    
    process = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon-graph"] style:UIBarButtonItemStylePlain target:self action:@selector(processSelection:)];
    sentiment = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon-sentiment"] style:UIBarButtonItemStylePlain target:self action:@selector(showSentiment:)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:process, sentiment, nil];
    [process setEnabled:NO];
    [sentiment setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addNewBook:(id)sender {
    [self performSegueWithIdentifier:@"AddBookSegue" sender:sender];
    [(AddBookViewController *)self.presentedViewController setParent:self];
}

- (void)addNewBookWithText:(NSString *)text title:(NSString *)title {
    [self performSegueWithIdentifier:@"AddBookSegue" sender:nil];
    [(AddBookViewController *)self.presentedViewController setBookText:text];
    [[(AddBookViewController *)self.presentedViewController bookTitle] setText:title];
    [(AddBookViewController *)self.presentedViewController setParent:self];
}

- (void)setFilters:(id)sender {
    [self performSegueWithIdentifier:@"SetLibraryFiltersSegue" sender:sender];
}

- (void)saveAndProcessBookInfo:(BookInfo *)info {
    _currentBookInfo = info;
    [self performSegueWithIdentifier:@"ProcessBookSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ProcessBookSegue"]) {
        BookProcessingViewController * bpvc = [segue destinationViewController];
        [bpvc setBookInfo:_currentBookInfo];
    }
    else if ([segue.identifier isEqualToString:@"ShowVisualisationSegue"]) {
        VisualisationTabBarController * vtbc = [segue destinationViewController];
        [vtbc setCollection:_currentCollection];
    }
    else if ([segue.identifier isEqualToString:@"GraphSegue"]) {
        GraphViewController * viewController = [segue destinationViewController];
        Book * book = [_currentCollection.books allObjects].firstObject;
        [viewController setBook:book];
    }
    else if ([segue.identifier isEqualToString:@"AnnotateSegue"]) {
        AnnotationsViewController * viewController = [segue destinationViewController];
        [viewController setBookInfo:_annotationBookInfo];
        viewController.delegate = self;
    }
    
}

- (IBAction)processSelection:(id)sender {

    MBProgressHUD * HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	HUD.labelText = @"Loading Books";
	
	[HUD showWhileExecuting:@selector(loadBooksAndSegue:) onTarget:self withObject:@"ShowVisualisationSegue" animated:YES];
    
}

- (IBAction)showSentiment:(id)sender {
    
    MBProgressHUD * HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	HUD.labelText = @"Loading Books";
	
	[HUD showWhileExecuting:@selector(loadBooksAndSegue:) onTarget:self withObject:@"GraphSegue" animated:YES];
    
}

- (void)loadBooksAndSegue:(NSString *)segue {
    NSMutableSet * books = [NSMutableSet set];
    for (BookInfo * info in _selectedBooks) {
        [books addObject:[Library loadBookWithInfo:info]];
    }
    _currentCollection = [BookCollection collectionWithBooks:books];
    
    [self performSegueWithIdentifier:segue sender:nil];
}

- (void)reloadLibrary {
    bookInfoArray = [Library loadLibrary];
    
    if ([bookInfoArray count] > 0) {
        [_emptyLibrary setHidden:YES];
    }
    [self.collectionView reloadData];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [bookInfoArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BookViewCell * bookViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookViewCell" forIndexPath:indexPath];
    BookInfo * bookInfo = [bookInfoArray objectAtIndex:indexPath.row];
    NSLog(@"BOOKINFO : Title : %@, Words : %d, Edges : %d, Sentiment : %f", bookInfo.title, bookInfo.nodeCount, bookInfo.edgeCount, bookInfo.sentiment);
    [bookViewCell setTitleText:bookInfo.title];
    [bookViewCell setAuthorText:bookInfo.author];
    [bookViewCell setCoverImage:bookInfo.imageURL];
    [bookViewCell.wordCount setText:[NSString stringWithFormat:@("%d Words"), bookInfo.nodeCount]];
    [bookViewCell.pairCount setText:[NSString stringWithFormat:@("%d Pairs"), bookInfo.edgeCount]];
    
    if (bookInfo.sentiment >= 0.2) {
        [bookViewCell.sentimentButton setTitle:@"Very Positive" forState:UIControlStateNormal];
        [bookViewCell.sentimentButton setTitleColor:UIColorFromRGB(0x39b54a) forState:UIControlStateNormal];
        [bookViewCell.sentimentButton setImage:[UIImage imageNamed:@"very-positive.png"] forState:UIControlStateNormal];
    } else
    if (bookInfo.sentiment < 0.2 && bookInfo.sentiment >= 0.01) {
        [bookViewCell.sentimentButton setTitle:@"Positive" forState:UIControlStateNormal];
        [bookViewCell.sentimentButton setTitleColor:UIColorFromRGB(0xc4df9b) forState:UIControlStateNormal];
        [bookViewCell.sentimentButton setImage:[UIImage imageNamed:@"positive.png"] forState:UIControlStateNormal];
    } else
    if (bookInfo.sentiment < 0.01 && bookInfo.sentiment > -0.01) {
        [bookViewCell.sentimentButton setTitle:@"Neutral" forState:UIControlStateNormal];
        [bookViewCell.sentimentButton setTitleColor:UIColorFromRGB(0xcccccc) forState:UIControlStateNormal];
        [bookViewCell.sentimentButton setImage:[UIImage imageNamed:@"neutral.png"] forState:UIControlStateNormal];
    } else
    if (bookInfo.sentiment > -0.2 && bookInfo.sentiment <= -0.01) {
        [bookViewCell.sentimentButton setTitle:@"Negative" forState:UIControlStateNormal];
        [bookViewCell.sentimentButton setTitleColor:UIColorFromRGB(0xf26d6d) forState:UIControlStateNormal];
        [bookViewCell.sentimentButton setImage:[UIImage imageNamed:@"negative.png"] forState:UIControlStateNormal];
    } else {
        [bookViewCell.sentimentButton setTitle:@"Very Negative" forState:UIControlStateNormal];
        [bookViewCell.sentimentButton setTitleColor:UIColorFromRGB(0xed1c24) forState:UIControlStateNormal];
        [bookViewCell.sentimentButton setImage:[UIImage imageNamed:@"very-negative.png"] forState:UIControlStateNormal];
    }
    
    if ([_selectedBooks containsObject:bookInfo]) {
        bookViewCell.backgroundColor = UI_HIGHLIGHT_BLUE;
    }
    
    NSSet * annotations = [Library annotationsForBook:bookInfo.UUID];
    
    if (annotations.count == 0) {
        [bookViewCell.annotationsButton setImage:[UIImage imageNamed:@"annotations-no.png"] forState:UIControlStateNormal];
        [bookViewCell.annotationsButton setTitleColor:UIColorFromRGB(0xc4c4c4) forState:UIControlStateNormal];
        [bookViewCell.annotationsButton setTitle:@"No Annotations" forState:UIControlStateNormal];
    } else {
        [bookViewCell.annotationsButton setImage:[UIImage imageNamed:@"annotations-yes.png"] forState:UIControlStateNormal];
        [bookViewCell.annotationsButton setTitleColor:UIColorFromRGB(0x007aff) forState:UIControlStateNormal];
        [bookViewCell.annotationsButton setTitle:[NSString stringWithFormat:@"%d Annotations", annotations.count] forState:UIControlStateNormal];
    }
    
    return bookViewCell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BookInfo * bookInfo = [bookInfoArray objectAtIndex:indexPath.row];
    if ([_selectedBooks containsObject:bookInfo]) {
        [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BookInfo * correspondingInfo = [bookInfoArray objectAtIndex:indexPath.row];
    NSLog(@"Selected Book in library : %@", correspondingInfo.title);
    BookViewCell * cell = (BookViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:YES];
    [_selectedBooks addObject:correspondingInfo];
    [process setEnabled:([_selectedBooks count] > 0) ? YES : NO];
    [sentiment setEnabled:([_selectedBooks count] == 1) ? YES : NO];
    NSLog(@"Currently selected %lu books.", (unsigned long)[_selectedBooks count]);
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    BookInfo * correspondingInfo = [bookInfoArray objectAtIndex:indexPath.row];
    NSLog(@"Deselected Book in library : %@", correspondingInfo.title);
    BookViewCell * cell = (BookViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:NO];
    [_selectedBooks removeObject:correspondingInfo];
    [sentiment setEnabled:([_selectedBooks count] == 1) ? YES : NO];
    NSLog(@"Currently selected %lu books.", (unsigned long)[_selectedBooks count]);
}

- (IBAction)showAnnotations:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        _annotationBookInfo = [bookInfoArray objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"AnnotateSegue" sender:self];
    }
}

#pragma mark AnnotationProtocol

- (void)reloadAnnotations {
    [self reloadLibrary];
}

- (void)clearLibCache {
    NSLog(@"Clear Cache");
    _currentCollection = nil;
    _currentCollection = [[BookCollection alloc] init];
    [Library clearCache];
}

@end
