//
//  PictureViewController.h
//  Test
//
//  Created by Y. Liu on 4/21/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAsset.h>

@interface PictureViewController : UIViewController

@property (strong, nonatomic) ALAsset *photoAsset;
@property (strong, nonatomic) NSString *tag;
@property (strong, nonatomic) NSString *diary;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *weather;

@end

