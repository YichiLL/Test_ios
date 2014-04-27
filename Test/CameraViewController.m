//
//  CamViewController.m
//  Test
//
//  Created by Y. Liu on 3/24/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "CameraViewController.h"
#import "DatabaseAvailability.h"
#import "Photo.h"
#import "Photo+Create.h"

@interface CameraViewController ()

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic,weak) UIImage *imageToSave;
@property (weak, nonatomic) IBOutlet UIButton *captureMomentButton;
@property (nonatomic) BOOL viewShowed;

@end

@implementation CameraViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewShowed=NO;
    self.navigationController.delegate=self;
    NSLog(@"Did set %@ as delegate" , NSStringFromClass(self.class));
    NSLog(@"viewDidLoad");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    NSLog(@"viewWillAppear");

    if (!self.viewShowed) {
        NSLog(@"actual show");
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        
        imagePickerController.showsCameraControls = NO;
        
        [[NSBundle mainBundle] loadNibNamed:@"cameraView" owner:self options:nil];
        self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
        imagePickerController.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
        
        self.imagePickerController = imagePickerController;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
        self.captureMomentButton.hidden=YES;
    }
    self.viewShowed=NO;
}

#pragma mark - respond to button clicks
- (IBAction)captureMoment:(id)sender {
    self.viewShowed=YES;
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self performSegueWithIdentifier:@"capture" sender:self];
}

- (IBAction)back:(id)sender
{
    [self saveDocument];
    self.viewShowed=YES;
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)takePicture:(id)sender {
    [self.imagePickerController takePicture];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.imageToSave = image;
    
    //    try printing metadata
    
    NSMutableDictionary *metadataDict = [info objectForKey:UIImagePickerControllerMediaMetadata];
    if (metadataDict) {
        NSLog(@"Below is everything in the metadata");
        for(NSString *key in [metadataDict allKeys]) {
            NSLog(@"%@:%@",key,[metadataDict objectForKey:key]);
        }
        NSLog(@"END Below is everything in the metadata");
        NSLog(@"Retrieve DateTimeOriginal as NSString: %@", [[metadataDict objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"]);
    }
    
//    NSMutableDictionary *metadataDict = [[NSMutableDictionary  alloc]init];
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.1f) {
//        NSURL* assetURL = nil;
//        if ((assetURL = [info objectForKey:UIImagePickerControllerReferenceURL])) {
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            [library assetForURL:assetURL
//                     resultBlock:^(ALAsset *asset)  {
//                         NSDictionary *metadata = asset.defaultRepresentation.metadata;
//                         [metadataDict addEntriesFromDictionary:metadata];
//                     }
//                    failureBlock:^(NSError *error) {
//                    }];
//        }
//        else {
//            [metadataDict addEntriesFromDictionary: [info objectForKey:UIImagePickerControllerMediaMetadata]];
//            
//        }
//    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:((UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage]).CGImage
                                 metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              Photo *photo = [Photo photoWithAssetURL:assetURL inManagedObejctContext:self.managedObjectContext];
                              if (metadataDict) {
                                  photo.takeDate=[NSDate date];
                                  NSLog(@"Take Date to be saved: %@",photo.takeDate);
                              } else {
                                  NSLog(@"Could not load metadata.");
                              }
                              NSLog(@"Saved Picture at assetURL: %@", assetURL);
                          }];

    self.captureMomentButton.hidden=NO;
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideWithAnimation) userInfo:nil repeats:NO];
}

- (void)saveDocument
{
    [self.managedDocument saveToURL:self.managedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success) {
            NSLog(@"After saving");
        }
        else NSLog(@"Failed to Save.");
    }];

}

- (void)hideWithAnimation {
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{self.captureMomentButton.hidden=YES;}
                     completion:NULL];
}

@end
