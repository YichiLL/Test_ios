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
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSDictionary *data;

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
    [self.imagePickerController dismissViewControllerAnimated:NO completion:NULL];
    [self performSegueWithIdentifier:@"capture" sender:self];
}

- (IBAction)back:(id)sender
{
    [self.imagePickerController dismissViewControllerAnimated:NO completion:NULL];
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
//    if (metadataDict) {
//        NSLog(@"Below is everything in the metadata");
//        for(NSString *key in [metadataDict allKeys]) {
//            NSLog(@"%@:%@",key,[metadataDict objectForKey:key]);
//        }
//        NSLog(@"END Below is everything in the metadata");
//        NSLog(@"Retrieve DateTimeOriginal as NSString: %@", [[metadataDict objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"]);
//    }

    // Preconstruct a Photo object for capturing tags
    self.photo = [Photo emptyPhotoInManagedObejctContext:self.managedObjectContext];
    NSDate *now =[NSDate date];
    self.photo.takeDateUTC = now;
    self.photo.timeZoneOffsetInHour = [NSNumber numberWithDouble:([[NSTimeZone localTimeZone] secondsFromGMT] / 3600.0)];
//    NSLog(@"Hours different from GMT: %@", self.photo.timeZoneOffsetInHour);

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
    [self populateWeatherForLocation:currentLocation withPhoto:currentPhoto];
//    NSLog(@"TimeZone = %@", currentPhoto.takeTimeZone);
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

#pragma mark - Weather API
- (void)populateWeatherForLocation:(CLLocation *)location withPhoto:(Photo *)photo
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%F&lon=%F&units=imperial",location.coordinate.latitude, location.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
//    NSLog(@"Fetching: %@",url.absoluteString);

    if(!self.session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (! error) {
            NSError *jsonError = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            if (!jsonError) {
//                NSLog(@"Json parsed = %@", json);
                [self updatePhoto:photo withData:json];
            }
            else {
                NSLog(@"Json cannot be parsed = %@", jsonError);
            }
        }
        else {
            NSLog(@"Error in sending request = %@", error);
        }
    }];

    [dataTask resume];
}

#define WTHR_RESULT_WEATHERS                @"weather"
#define WTHR_RESULT_WEATHER_DESCRIPTIONS    @"weather.description"
#define WTHR_RESULT_WEATHER_CATEGORIES      @"weather.main"
#define WTHR_RESULT_TEMPERATURE             @"main.temp"
#define WTHR_RESULT_HUMIDITY                @"main.humidity"
#define WTHR_RESULT_CLOUDS                  @"clouds.all"
#define WTHR_RESULT_WIND_SPEED              @"wind.speed"
#define WTHR_RESULT_LATITUDE                @"coord.lat"
#define WTHR_RESULT_LONGITUDE               @"coord.lon"

- (void)updatePhoto:(Photo *)photo withData:(NSDictionary *)data
{
//    id weathers = [data valueForKeyPath:WTHR_RESULT_WEATHERS];
    id descriptions = [data valueForKeyPath:WTHR_RESULT_WEATHER_DESCRIPTIONS];
    id categories = [data valueForKeyPath:WTHR_RESULT_WEATHER_CATEGORIES];
    id temp = [data valueForKeyPath:WTHR_RESULT_TEMPERATURE];
    id humidity = [data valueForKeyPath:WTHR_RESULT_HUMIDITY];
    id clouds = [data valueForKeyPath:WTHR_RESULT_CLOUDS];
    id wind_speed = [data valueForKeyPath:WTHR_RESULT_WIND_SPEED];
    id latitude = [data valueForKeyPath:WTHR_RESULT_LATITUDE];
    id longitude = [data valueForKeyPath:WTHR_RESULT_LONGITUDE];

//    NSLog(@"weathers = %@", weathers);
//    NSLog(@"descriptions = %@", [descriptions firstObject]);
//    NSLog(@"categories = %@", [categories firstObject]);
//    NSLog(@"temprature = %@", temp);
//    NSLog(@"humidity = %@", humidity);
//    NSLog(@"clouds = %@", clouds);
//    NSLog(@"wind_speed = %@", wind_speed);
//    NSLog(@"latitude = %@", latitude);
//    NSLog(@"longitude = %@", longitude);

    photo.weatherDescription = [descriptions firstObject];
    photo.weatherCategory = [categories firstObject];
    photo.weatherTemperature = temp;
    photo.weatherHumidity = humidity;
    photo.weatherClouds = clouds;
    photo.weatherWindSpeed = wind_speed;
    photo.weatherLatitude = latitude;
    photo.weatherLongitude = longitude;
}

@end
