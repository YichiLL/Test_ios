//
//  CamViewController.m
//  Test
//
//  Created by Y. Liu on 3/24/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AddressBookUI/AddressBookUI.h>
#import "CameraViewController.h"
#import "CaptureMomentViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DatabaseAvailability.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "Photo.h"
#import "Photo+Create.h"

@interface CameraViewController () <CLLocationManagerDelegate>

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic,weak) UIImage *imageToSave;
@property (weak, nonatomic) IBOutlet UIButton *captureMomentButton;
@property (nonatomic) BOOL viewShowed;
@property (strong, nonatomic) Photo *photo;
@property (strong, nonatomic) NSTimer *oldTimer;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) CLHeading * lastHeading;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation CameraViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewShowed=NO;

    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // meters
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
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
    NSLog(@"Camera - viewWillDisappear");
    // Do cleaning, saving here
    // Be aware that this is called when imagePickerController is dismissed
    [self saveDocument];
}

#pragma mark - getters
- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }

    return _locationManager;
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (_assetsLibrary == nil)
    {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder)
        _geocoder = [[CLGeocoder alloc] init];
    return _geocoder;
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
    // Hide old button if already present
    // later to present new button to process the latest picture taken
    self.captureMomentButton.hidden=YES;
    [self.oldTimer invalidate];

    // Prepare new image to be saved
    self.photo = nil;
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.imageToSave = image;
    
    NSMutableDictionary *metadataDict = [info objectForKey:UIImagePickerControllerMediaMetadata];

    // Printin metadata information. for debugging purpose
    if (metadataDict) {
        NSLog(@"Below is everything in the metadata");
        for(NSString *key in [metadataDict allKeys]) {
            NSLog(@"%@:%@",key,[metadataDict objectForKey:key]);
        }
        NSLog(@"END Below is everything in the metadata");
        NSLog(@"Retrieve DateTimeOriginal as NSString: %@", [[metadataDict objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"]);
    }

    // Preconstruct a Photo object for capturing tags
    self.photo = [Photo emptyPhotoInManagedObejctContext:self.managedObjectContext];
    NSDate *now =[NSDate date];
    self.photo.takeDateUTC = now;
    self.photo.timeZoneOffsetInHour = [NSNumber numberWithDouble:([[NSTimeZone localTimeZone] secondsFromGMT] / 3600.0)];
    NSLog(@"Hours different from GMT: %@", self.photo.timeZoneOffsetInHour);

    // store metadata when storing to album
    Photo *currentPhoto = self.photo;
    CLLocation *currentLocation = self.lastLocation;
    CLHeading *currentHeading = self.lastHeading;
    if (currentLocation) {
        [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if (error) {
                 NSLog(@"Geocoding failed with location = %@, localized description = %@", currentLocation, [error localizedDescription]);
             } else {
                 CLPlacemark *placeMark = [placemarks firstObject];
                 currentPhoto.addressRegions = [NSString stringWithFormat:@"%@, %@, %@, %@, %@", placeMark.subLocality, placeMark.locality, placeMark.subAdministrativeArea, placeMark.administrativeArea, placeMark.country];
//                 NSLog(@"Address Regions = %@", currentPhoto.addressRegions);
                 currentPhoto.addressFull = ABCreateStringWithAddressDictionary(placeMark.addressDictionary, TRUE);
//                 NSLog(@"Address Full = %@", currentPhoto.addressFull);
             }
         }];
    }
    [metadataDict setLocation:currentLocation];
    [metadataDict setHeading:currentHeading];
    currentPhoto.gpsLongitude = [NSNumber numberWithDouble:currentLocation.coordinate.longitude];
    currentPhoto.gpsLatitude = [NSNumber numberWithDouble:currentLocation.coordinate.latitude];
    currentPhoto.gpsSpeed = [NSNumber numberWithDouble:currentLocation.speed];
    currentPhoto.gpsCourse = [NSNumber numberWithDouble:currentLocation.course];
    currentPhoto.locationTimeStamp = currentLocation.timestamp;
    currentPhoto.takeTimeZone = [[NSTimeZone localTimeZone] name];
    NSLog(@"TimeZone = %@", currentPhoto.takeTimeZone);
    [self.assetsLibrary writeImageToSavedPhotosAlbum:((UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage]).CGImage
                                 metadata:metadataDict
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              if (error) {
                                  NSLog(@"Error occurred, content of NSError: %@", error);
                              } else {
                                  currentPhoto.assetURL = [assetURL absoluteString];
                                  NSLog(@"Saved Picture at assetURL: %@", assetURL);
                              }
                          }];

    // Show button to capture more details about current picture
    self.captureMomentButton.hidden=NO;
    self.oldTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideWithAnimation) userInfo:nil repeats:NO];
}

- (void)hideWithAnimation {
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{self.captureMomentButton.hidden=YES;}
                     completion:NULL];
}

# pragma mark - Metadata generating
- (NSDate *)getLocalDate:(NSDate *)sourceDate {
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

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (locations) {
        self.lastLocation = [locations lastObject];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    self.lastHeading = newHeading;
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
