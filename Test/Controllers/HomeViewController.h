//
//  CustomViewController.h
//  Test
//
//  Created by Y. Liu on 4/21/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface HomeViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIManagedDocument *managedDocument;

@end
