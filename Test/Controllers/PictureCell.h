//
//  PictureCell.h
//  TripGo
//
//  Created by Jayson Ng on 5/4/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureCell : UICollectionViewCell
@property (nonatomic, copy) UIImage *image;
@property(nonatomic, strong) IBOutlet UIImageView *imageView;
@end
