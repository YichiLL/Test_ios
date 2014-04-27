//
//  CamViewController.h
//  Test
//
//  Created by Y. Liu on 3/24/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIManagedDocument *managedDocument;

@end
