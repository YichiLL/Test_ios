//
//  PictureViewController.h
//  Test
//
//  Created by Y. Liu on 4/21/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAsset.h>
#import "Photo.h"

@interface PictureViewController : UIViewController

@property (strong, nonatomic) ALAsset *photoAsset;
@property (strong, nonatomic) Photo *photoManagedDocumentObject;

@end

