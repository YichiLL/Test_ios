//
//  CamViewController.m
//  Test
//
//  Created by Y. Liu on 3/24/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "CameraViewController.h"
#import "CaptureMomentViewController.h"
#import "DatabaseAvailability.h"
#import "Photo.h"
#import "Photo+Create.h"

@interface CameraViewController ()

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic,weak) UIImage *imageToSave;
@property (weak, nonatomic) IBOutlet UIButton *captureMomentButton;
@property (nonatomic) BOOL viewShowed;
@property (strong, nonatomic) Photo *photo;

@end

@implementation CameraViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewShowed=NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"Camera - viewWillAppear");

    if (!self.viewShowed) {
        NSLog(@"Camera - showing imagePickerController");
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
        self.viewShowed=YES;
    } else {self.viewShowed=NO;
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"Camera - viewWillDisppear");
    // Do cleaning, saving here
    // Be aware that this is called when imagePickerController is dismissed
    [self saveDocument];
}

#pragma mark - respond to button clicks
- (IBAction)captureMoment:(id)sender {
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self performSegueWithIdentifier:@"capture" sender:self];
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)takePicture:(id)sender {
    [self.imagePickerController takePicture];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.photo = nil;
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.imageToSave = image;
    
    //    try printing metadata
//    NSMutableDictionary *metadataDict = [info objectForKey:UIImagePickerControllerMediaMetadata];
//    if (metadataDict) {
//        NSLog(@"Below is everything in the metadata");
//        for(NSString *key in [metadataDict allKeys]) {
//            NSLog(@"%@:%@",key,[metadataDict objectForKey:key]);
//        }
//        NSLog(@"END Below is everything in the metadata");
//        NSLog(@"Retrieve DateTimeOriginal as NSString: %@", [[metadataDict objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"]);
//    }
    
    // store metadata when storing to album
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:((UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage]).CGImage
                                 metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              Photo *photo = [Photo photoWithAssetURL:assetURL inManagedObejctContext:self.managedObjectContext];
                              if (YES) {
                                  photo.takeDate=[self getLocalDate];
                                  self.photo = photo;

                                  //TODO actual user input is needed. Below just some random tags
                                  NSArray *tagChoice = @[@"Happy", @"Fun"];
                                  NSArray *weatherChoice = @[@"cloudy", @"sunny"];

                                  self.photo.weather = weatherChoice[arc4random_uniform(2)];
                                  self.photo.tag = tagChoice[arc4random_uniform(2)];
                                  
                                  // TODO move following two lines out of the block; instead, pass photo to another class, whose instance will be
                                  // hold strongly by all VCs saving on the same photo. Or creat a unique key for each Photo, so don't have to wait Photo is
                                  // done to pass it to the next VC. can just pass key
                                  self.captureMomentButton.hidden=NO;
                                  [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideWithAnimation) userInfo:nil repeats:NO];
                                  NSLog(@"Take Date to be saved: %@",photo.takeDate);
                              } else {
                                  NSLog(@"Could not load metadata.");
                              }
                              NSLog(@"Saved Picture at assetURL: %@", assetURL);
                              NSLog(@"weather: %@, tag: %@",photo.weather,photo.tag);
                              
                              
                          }];


}

- (void)hideWithAnimation {
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{self.captureMomentButton.hidden=YES;}
                     completion:NULL];
}

# pragma mark - Metadata generating
- (NSDate *)getLocalDate {
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    return destinationDate;
}

# pragma mark - Saving Document
- (void)saveDocument
{
    NSLog(@"Saving Called");
    [self.managedDocument saveToURL:self.managedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success) {
            NSLog(@"After saving");
        }
        else NSLog(@"Failed to Save.");
    }];

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"capture"])
    {
        if ([segue.destinationViewController isKindOfClass:[CaptureMomentViewController class]])
        {
            CaptureMomentViewController *cmvc = segue.destinationViewController;
            cmvc.photo = self.photo;
        }

    }
}

@end
