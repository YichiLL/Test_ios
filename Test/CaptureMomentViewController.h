//
//  CaptureMomentViewController.h
//  Test
//
//  Created by Y. Liu on 3/24/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Photo.h"

@interface CaptureMomentViewController : UIViewController

@property (strong, nonatomic) Photo* photo;
@property (strong, nonatomic) UIManagedDocument *managedDocument;

@end
