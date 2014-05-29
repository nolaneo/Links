//
//  AddBookViewController.m
//  Links
//
//  Created by Eoin Nolan on 14/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "AddBookViewController.h"
#import "LibraryViewController.h"
#import "UIImageView+WebCache.h"
#import "Definitions.h"
#import "CopyLabel.h"
#import "BookInfo.h"
#import "SearchResult.h"
#import "SearchResultCell.h"

@interface AddBookViewController ()
@property NSMutableArray * searchResults;
@property IBOutlet UIView * mainContainer;
@property IBOutlet UIView * searchContainer;
@property IBOutlet UIView * allResultsContainer;
@property IBOutlet UIView * resultsContainer;
@property IBOutlet UIView * errorContainer;
@property UITapGestureRecognizer * tapBehindGesture;
//Main
@property IBOutlet UITextField * bookAuthor;
@property IBOutlet CopyLabel * pasteInputField;
//Search
@property IBOutlet UIActivityIndicatorView * onlineCheckProgress;
//All Results
@property IBOutlet UITableView * resultsTable;
//Results
@property IBOutlet UILabel * titleLabel;
@property IBOutlet UIImageView * bookCover;
@property IBOutlet UILabel * authorLabel;
@property IBOutlet UILabel * ISBNLabel;
@property IBOutlet UILabel * yearLabel;
@property IBOutlet UITextView * descriptionView;

@property IBOutlet UIButton * useResults;
@property IBOutlet UIButton * ignoreResults;

@property NSString * url;
@end

@implementation AddBookViewController

static NSOperationQueue * queue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pasteInputField.parent = self;
    self.navigationItem.title = @"Add a New Book";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(checkOnline:)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    _searchResults = [NSMutableArray array];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setupTapRecognizer];
    [_bookTitle becomeFirstResponder];
}

- (void)setBookText:(NSString *)text {
    self.text = text;
    NSLog(@"Text : %@", self.text);
    [_pasteInputField setText:@"Text Loaded"];
    [_pasteInputField setTextColor:[UIColor darkTextColor]];
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


- (void)setupUI {
    [_searchContainer setAlpha:0.0f];
    [_allResultsContainer setAlpha:0.0f];
    [_resultsContainer setAlpha:0.0f];
    [_errorContainer setAlpha:0.0f];

    [self.bookAuthor setBorderStyle:UITextBorderStyleRoundedRect];
    [self.bookTitle setBorderStyle:UITextBorderStyleRoundedRect];
    [_pasteInputField.layer setBorderColor:UI_STROKE_GREY.CGColor];
    [_pasteInputField.layer setBorderWidth:1.0f];
    [_pasteInputField.layer setCornerRadius:8.0f];
    [_pasteInputField setTextColor:UI_STROKE_GREY];
}


- (IBAction)saveBookWithResults:(id)sender {
    
    BookInfo * info = [[BookInfo alloc] init];
    info.title  = (sender == _useResults) ? _titleLabel.text : _bookTitle.text;
    info.author = (sender == _useResults) ? _authorLabel.text : _bookAuthor.text;
    info.text = self.text;
    if (sender == _useResults) {
        info.imageURL = _url;
        info.ISBN = _ISBNLabel.text;
        info.publicationYear = _yearLabel.text;
        info.description = _descriptionView.text;
    }
    [self.view.window removeGestureRecognizer:_tapBehindGesture];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.parent saveAndProcessBookInfo:info];
    }];
    
}

- (IBAction)checkOnline:(id)sender {
    [self dismissKeyboard];
    [UIView animateWithDuration:0.5 animations:^{[_mainContainer setAlpha:0.0f];}];
    [UIView animateWithDuration:0.5 animations:^{[_searchContainer setAlpha:1.0f];}];
    //[self checkGoodReads];
    [self checkGoogleBooks];
}

- (IBAction)showAllResults:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{[_resultsContainer setAlpha:0.0f];}];
    [UIView animateWithDuration:0.5 animations:^{[_allResultsContainer setAlpha:1.0f];}];
}

-(void)dismissKeyboard {
    [self.bookAuthor resignFirstResponder];
    [self.bookTitle resignFirstResponder];
    [_pasteInputField resignFirstResponder];
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (void)checkGoogleBooks {
    
    NSString * author = @"";
    if (self.bookAuthor.text != nil) {
        author = [self.bookAuthor.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        author = [NSString stringWithFormat:@"+inauthor:%@", author];
    }
    NSString * title = @"";
    if (self.bookTitle.text != nil) {
        title = [self.bookTitle.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        title = [NSString stringWithFormat:@"intitle:%@", title];
    }
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=%@%@&orderBy=relevance", title, author]];
    NSLog(@"GET : %@", url.absoluteString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    if (queue == nil) {
        queue = [[NSOperationQueue alloc] init];
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        
        NSError *error = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        
        if(!error) {
            NSDictionary * results = object;
            
            NSArray * items = [results objectForKey:@"items"];
            if ([items count] < 1) {
                NSLog(@"Error : JSON Items empty");
                [self apiError];
                return;
            }
            NSLog(@"JSON items count : %d", [items count]);
            [_searchResults removeAllObjects];
            for (NSDictionary * item in items) {
                SearchResult * searchResult = [[SearchResult alloc] init];
                searchResult.title       = [[item objectForKey:@"volumeInfo"] objectForKey:@"title"];
                searchResult.author      = [[[item objectForKey:@"volumeInfo"] objectForKey:@"authors"] objectAtIndex:0];
                searchResult.description = [[item objectForKey:@"volumeInfo"] objectForKey:@"description"];
                searchResult.year        = [[[item objectForKey:@"volumeInfo"] objectForKey:@"publishedDate"] substringToIndex:4];
                searchResult.ISBN        = [[[[item objectForKey:@"volumeInfo"] objectForKey:@"industryIdentifiers"] objectAtIndex:0] objectForKey:@"identifier"];
                searchResult.imageURL    = [[[item objectForKey:@"volumeInfo"] objectForKey:@"imageLinks"] objectForKey:@"thumbnail"];
                [_searchResults addObject:searchResult];
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [_resultsTable reloadData];
                [UIView animateWithDuration:0.5 animations:^{[_searchContainer setAlpha:0.0f];}];
                [UIView animateWithDuration:0.5 animations:^{[_allResultsContainer setAlpha:1.0f];}];
            }];
            
        } else {
            [self apiError];
        }
    }];
}

- (void)apiError {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:0.5 animations:^{[_searchContainer setAlpha:0.0f];}];
        [UIView animateWithDuration:0.5 animations:^{[_errorContainer setAlpha:1.0f];}];
    }];
}

- (void)showSearchResult:(SearchResult *)result {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _url = result.imageURL;
        [_bookCover setImageWithURL:[NSURL URLWithString:result.imageURL]];
        [_titleLabel setText:result.title];
        [_authorLabel setText:result.author];
        [_ISBNLabel setText:result.ISBN];
        [_yearLabel setText:result.year];
        [_descriptionView setText:result.description];
        [UIView animateWithDuration:0.5 animations:^{[_allResultsContainer setAlpha:0.0f];}];
        [UIView animateWithDuration:0.5 animations:^{[_resultsContainer setAlpha:1.0f];}];
    }];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"SearchResultCell";
    SearchResultCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    SearchResult * result = [_searchResults objectAtIndex:indexPath.row];
    [cell.coverImageView setImageWithURL:[NSURL URLWithString:result.imageURL]];
    [cell.titleLabel setText:result.title];
    [cell.authorLabel setText:result.author];
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SearchResult * result = [_searchResults objectAtIndex:indexPath.row];
    [self showSearchResult:result];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == _bookTitle) {
        [_bookAuthor becomeFirstResponder];
    } else {
        [self checkOnline:nil];
    }
    return YES;
}

@end
