//
//  YCLCustomViewController.m
//  Test
//
//  Created by Y. Liu on 4/21/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "CustomViewController.h"
#import "PictureViewController.h"

@interface CustomViewController ()

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSArray *photos;

@end

@implementation CustomViewController

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
    // Do any additional setup after loading the view.
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self loadPhotos];
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (_assetsLibrary == nil)
    {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Picture"]) {
        PictureViewController *pvc = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.collectionView.indexPathsForSelectedItems objectAtIndex:0];
        ALAsset *photoAsset = [self.photos objectAtIndex:selectedIndexPath.row];
        pvc.photoAsset = photoAsset;
    }
}


#pragma mark - UI Collection View Data Source
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
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        self.photos = photos;
        [self.collectionView reloadData];
        
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PhotoCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
    cell.contentView.layer.contents = (id)asset.thumbnail;
    
    return cell;
}


@end
