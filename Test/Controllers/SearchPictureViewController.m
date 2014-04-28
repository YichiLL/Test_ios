//
//  SearchPictureViewController.m
//  TripGo
//
//  Created by Tom Hsu on 4/25/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Photo.h"
#import "SearchPictureViewController.h"

@interface SearchPictureViewController () <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *searchStatusLabel;

@end

@implementation SearchPictureViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = TRUE;
}

#pragma mark - getter/setter

- (void)setSearchTerm:(NSString *)searchTerm
{
    _searchTerm = searchTerm;
    if (_searchBar) {
        _searchBar.text = _searchTerm;
    }
}

- (void)setSearchBar:(UISearchBar *)searchBar
{
    _searchBar = searchBar;
    if (_searchTerm)
    {
        _searchBar.text = _searchTerm;
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchString = [searchBar text];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"(tag CONTAINS[cd] %@) OR (weather CONTAINS[cd] %@)", searchString, searchString];
    
    NSError *error;
    NSArray *matches = [self.context executeFetchRequest:request error:&error];
    
    if (!matches || error)
    {
        // handle error
    } else
    {
        self.searchStatusLabel.text = [NSString stringWithFormat:@"Found %u picture(s)", [matches count]];
    }
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
