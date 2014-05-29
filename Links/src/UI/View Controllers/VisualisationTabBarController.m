//
//  VisualisationTabBarController.m
//  Links
//
//  Created by Eoin Nolan on 19/03/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "VisualisationTabBarController.h"
#import "WordTableViewController.h"
#import "UserFilterViewController.h"
#import "SpiralViewController.h"
#import "MBProgressHUD.h"

@interface VisualisationTabBarController ()
@property UIBarButtonItem * filter;
@property UISearchBar * searchBar;
@end

@implementation VisualisationTabBarController
@synthesize filter;
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
    [self setupNavigationBar];
	[self setSelectedIndex:0];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar {
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.placeholder = @"Search for a word";
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    
    filter = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-filter"] style:UIBarButtonItemStylePlain target:self action:@selector(setFilters:)];
    
    self.navigationItem.rightBarButtonItem = filter;
}

- (void)setFilters:(id)sender {
    [self performSegueWithIdentifier:@"SetWordFiltersSegue" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SetWordFiltersSegue"]) {
        UserFilterViewController * ufvc = [segue destinationViewController];
        ufvc.collection = self.collection;
        ufvc.parent = self;
    }
}

- (void)reloadData {
    MBProgressHUD * HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Fetching Results";
    MBProgressHUDCompletionBlock completion = ^{
        WordTableViewController * wtvc = [[self childViewControllers] objectAtIndex:0];
        [wtvc reloadData];
        SpiralViewController * svc = [[self childViewControllers] objectAtIndex:1];
        [svc reloadData];
    };
    [HUD setCompletionBlock:completion];
    [HUD showWhileExecuting:@selector(applyFilters) onTarget:self.collection withObject:nil animated:YES];
}

#pragma UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.collection.searchString = searchText;
    WordTableViewController * wtvc = [[self childViewControllers] objectAtIndex:0];
    [wtvc searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end
