//
//  CustomViewController.m
//  Test
//
//  Created by Y. Liu on 4/21/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "CameraViewController.h"
#import "DatabaseAvailability.h"
#import "HomeViewController.h"
#import "Photo.h"
#import "PictureViewController.h"
#import "SearchPictureViewController.h"

@interface HomeViewController () <UISearchBarDelegate>

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSArray *photoAssets; // of ALAsset
@property (strong, nonatomic) NSMutableArray *fixedAssets; // of ALAsset
@property (strong, nonatomic) NSMutableArray *photosFromDatabase; // of ALAsset

@end

@implementation HomeViewController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.managedObjectContext = note.userInfo[DatabaseAvailabilityContext];
        self.managedDocument = note.userInfo[DatabaseAvailabilityDocument];
    }];
}

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
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(respondToDataChange)
//                                                 name:NSManagedObjectContextDidSaveNotification
//                                               object:self.managedObjectContext];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(respondToDataChange)
//                                                 name:NSManagedObjectContextObjectsDidChangeNotification
//                                               object:self.managedObjectContext];
//    [self loadPhotos];
//    [self initFixedPicture];
    [self initPhotoFromDatabase];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
}

- (void)respondToDataChange
{
    [self initPhotoFromDatabase];
}

#pragma mark - getter setter
- (ALAssetsLibrary *)assetsLibrary
{
    if (_assetsLibrary == nil)
    {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (NSMutableArray *) fixedAssets
{
    if (!_fixedAssets)
    {
        _fixedAssets = [[NSMutableArray alloc] init];
    }
    return _fixedAssets;
}

- (NSMutableArray *)photosFromDatabase
{
    if (!_photosFromDatabase)
    {
        _photosFromDatabase = [[NSMutableArray alloc] init];
    }
    return _photosFromDatabase;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
//    [self initFixedPicture];
    [self initPhotoFromDatabase];
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
    } else if ([segue.identifier isEqualToString:@"Take Picture"])
    {
        CameraViewController *cvc = segue.destinationViewController;
        cvc.managedDocument = self.managedDocument;
        cvc.managedObjectContext = self.managedObjectContext;
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
        if (index == 0) {
            NSURL *assetURL = [result valueForProperty:ALAssetPropertyAssetURL];
            NSLog(@"Asset URL is: %@", [assetURL absoluteString]);
        }
        
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

/*
Asset URL is: assets-library://asset/asset.JPG?id=70EC4E7C-F648-4862-B143-AF04AF455264&ext=JPG
 */
- (void) initFixedPicture
{
    [self.fixedAssets removeAllObjects];
    NSURL *fixedURL = [NSURL URLWithString:@"assets-library://asset/asset.JPG?id=70EC4E7C-F648-4862-B143-AF04AF455264&ext=JPG"];
    [self.assetsLibrary assetForURL:fixedURL resultBlock:^(ALAsset *asset) {
        [self.fixedAssets addObject:asset];
        [self.collectionView reloadData];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error finding the picture");
    }];
}

- (void) initPhotoFromDatabase
{
    if (!self.managedObjectContext) return;
    [self.photosFromDatabase removeAllObjects];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"assetURL"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    NSError *error;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!matches || error)
    {
        // handle error
    } else
    {
        for (Photo *photo in matches)
        {
            if (photo.assetURL)
                [self loadPhotoWithAssetURL:photo.assetURL];
        }
    }
}

- (void)loadPhotoWithAssetURL:(NSString *)assetURL
{
    [self.assetsLibrary assetForURL:[NSURL URLWithString:assetURL] resultBlock:^(ALAsset *asset) {
        if (asset){
            [self.photosFromDatabase addObject:asset];
            [self.collectionView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Error finding the picture with url: %@", assetURL);
    }];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return self.photoAssets.count;
//    return self.fixedAssets.count;
    return self.photosFromDatabase.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PhotoCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//    ALAsset *asset = [self.photoAssets objectAtIndex:indexPath.row];
//    ALAsset *asset = [self.fixedAssets objectAtIndex:indexPath.row];
    ALAsset *asset = [self.photosFromDatabase objectAtIndex:indexPath.row];
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
