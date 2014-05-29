//
//  AnnotationsViewController.m
//  Links
//
//  Created by Eoin Nolan on 06/05/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "AnnotationsViewController.h"
#import "Library.h"
#import "Annotation.h"
#import "AnnotationCell.h"
#import "Book.h"
#import "BookInfo.h"

@interface AnnotationsViewController ()
@property IBOutlet UIImageView * typeImage;
@property IBOutlet UILabel * typeLabel;
@property IBOutlet UITextView * textView;
@property NSArray * relatedAnnotations;
@end

@implementation AnnotationsViewController

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
	[_textView becomeFirstResponder];
    
    switch ([self getType]) {
        case NODE:
            [_typeImage setImage:[UIImage imageNamed:@"icon-word.png"]];
            [_typeLabel setText:[NSString stringWithFormat:@"Word Annotation : %@", self.node.word]];
            _relatedAnnotations = [[Library annotationsForNode:@(self.node.key)] allObjects];
            break;
        case EDGE:
            [_typeImage setImage:[UIImage imageNamed:@"icon-pair.png"]];
            [_typeLabel setText:[NSString stringWithFormat:@"Pair Annotation : %@ <--> %@", self.edge.left.word, self.edge.right.word]];
            _relatedAnnotations = [[Library annotationsForEdge:[self.edge key]] allObjects];
            break;
        case BOOK:
            [_typeImage setImage:[UIImage imageNamed:@"icon-book.png"]];
            [_typeLabel setText:[NSString stringWithFormat:@"Book Annotation : %@", self.bookInfo.title]];
            _relatedAnnotations = [[Library annotationsForBook:self.bookInfo.UUID] allObjects];
            break;
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)save:(id)sender {
    Annotation * annotation = [[Annotation alloc] init];
    annotation.type = [self getType];
    annotation.text = [_textView text];
    annotation.books = [Annotation getKey:self.books];
    NSMutableArray * titles = [NSMutableArray array];
    NSMutableSet * bookInfoSet = [NSMutableSet set];
    for (Book * book in self.books) {
        [titles addObject:book.bookInfo.title];
        [bookInfoSet addObject:book.bookInfo];
    }
    annotation.bookTitles = [titles componentsJoinedByString:@"\n"];

    switch (annotation.type) {
        case NODE:
            annotation.name = self.node.word;
            [Library addNodeAnnotation:annotation key:@(self.node.key) books:bookInfoSet];
            break;
        case EDGE:
            annotation.name = [NSString stringWithFormat:@"%@ <--> %@", self.edge.left.word, self.edge.right.word];
            [Library addEdgeAnnotation:annotation key:[self.edge key] books:bookInfoSet];
            break;
        case BOOK:
            annotation.name = self.bookInfo.title;
            [Library addBookAnnotation:annotation key:self.bookInfo.UUID];
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate reloadAnnotations];
    });
}

-(IBAction)cancel:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (AnnotationType)getType {
    if (self.bookInfo != nil) {
        return BOOK;
    } else if (self.node != nil) {
        return NODE;
    } else {
        return EDGE;
    }
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0, 0, 600, 900);
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_relatedAnnotations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnnotationCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AnnotationCell" forIndexPath:indexPath];
    
    Annotation * annotation = [_relatedAnnotations objectAtIndex:indexPath.row];
    
    switch (annotation.type) {
        case NODE:
            [cell.image setImage:[UIImage imageNamed:@"icon-word.png"]];
            [cell.type setText:@"WORD"];
            break;
        case EDGE:
            [cell.image setImage:[UIImage imageNamed:@"icon-pair.png"]];
            [cell.type setText:@"PAIR"];
            break;
        case BOOK:
            [cell.image setImage:[UIImage imageNamed:@"icon-book.png"]];
            [cell.type setText:@"BOOK"];
            break;
        default:
            break;
    }
    
    [cell.books setText:annotation.bookTitles];
    [cell.text setText:annotation.text];
    [cell.name setText:annotation.name];
    
    return cell;
}

#pragma mark UITableViewDelegate 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

@end
