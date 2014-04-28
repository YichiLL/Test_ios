//
//  SearchPictureViewController.h
//  TripGo
//
//  Created by Tom Hsu on 4/25/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchPictureViewController : UIViewController

@property (strong, nonatomic) NSString *searchTerm;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end
