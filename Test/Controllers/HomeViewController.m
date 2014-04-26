//
//  CustomViewController.m
//  Test
//
//  Created by Y. Liu on 4/21/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "HomeViewController.h"
#import "PictureViewController.h"
#import "SearchPictureViewController.h"

@interface HomeViewController () <UISearchBarDelegate>

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSArray *photoAssets; // of ALAsset

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadPhotos];
}

#pragma mark - Getters
- (ALAssetsLibrary *)assetsLibrary
{
    if (_assetsLibrary == nil)
    {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Picture"])
    {
        PictureViewController *pvc = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.collectionView.indexPathsForSelectedItems objectAtIndex:0];
        ALAsset *photoAsset = [self.photoAssets objectAtIndex:selectedIndexPath.row];
        pvc.photoAsset = photoAsset;
    } else if ([segue.identifier isEqualToString:@"Show Search Result"])
    {
        UISearchBar *searchBar = nil;
        if ([sender isKindOfClass:[UISearchBar class]]) {
            searchBar = (UISearchBar *) sender;
        }
        if (searchBar) {
            SearchPictureViewController *dvc = segue.destinationViewController;
            dvc.searchTerm = searchBar.text;
        }
    }
}

#pragma mark - Asset Loading

- (void)loadPhotos
{
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         
         if (!group)
             return;
         [self loadPhotosInGroup:group];
         *stop = YES;
         
     } failureBlock:^(NSError *error) {
         
         NSLog(@"Error enumerating asset groups: %@, %@", error, error.userInfo);
         
     }];

}

- (void)loadPhotosInGroup:(ALAssetsGroup *)assetsGroup
{
    __block NSMutableArray *photos = [NSMutableArray arrayWithCapacity:assetsGroup.numberOfAssets];
    [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (!result)
            return;
        
        [photos addObject:result];
        
    }];
    
    [self reloadCollectionViewWithPhotos:[photos copy]];
}

- (void)reloadCollectionViewWithPhotos:(NSArray *)photos
{
    // Sort the picture so newest pictures show up first
    self.photoAssets = [photos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [obj1 valueForProperty:ALAssetPropertyDate];
        NSDate *date2 = [obj2 valueForProperty:ALAssetPropertyDate];
        return ([date1 compare:date2] == NSOrderedAscending ? NSOrderedDescending : NSOrderedAscending);
    }];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self.collectionView reloadData];
        
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PhotoCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    ALAsset *asset = [self.photoAssets objectAtIndex:indexPath.row];
    cell.contentView.layer.contents = (id)asset.thumbnail;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;

    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        static NSString *cellIdentifier = @"Header with Search";
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    }

    return reusableView;

}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self performSegueWithIdentifier:@"Show Search Result" sender:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
