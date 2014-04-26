//
//  CamViewController.m
//  Test
//
//  Created by Y. Liu on 3/24/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "CameraViewController.h"
#import "DocumentHandler.h"
#import "Photo.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface CameraViewController ()
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic,weak) UIImage *imageToSave;

@property (weak, nonatomic) IBOutlet UIButton *captureMomentButton;

@property (nonatomic) BOOL viewShowed;


@property (nonatomic,strong) UIManagedDocument *document;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation CameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    NSLog(@"initWithNibName");
}

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
    
    
#pragma mark - Document
    
//    if (!self.document) {
//        [[YCLDocumentHandler sharedDocumentHandler] performWithDocument:^(UIManagedDocument *document) {
//            self.document = document;
//            // Do stuff with the document, set up a fetched results controller, whatever.
//        }];
//    }
    
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"PhotoMetadata"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [self.document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = self.document.managedObjectContext;
//                  [self refresh];
              }
          }];
    } else if (self.document.documentState == UIDocumentStateClosed) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = self.document.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = self.document.managedObjectContext;
    }
    
    
    
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

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:animated];
}

- (IBAction)captureMoment:(id)sender {
    self.viewShowed=YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:@"capture" sender:self];
}

- (IBAction) back: (id) sender
{
    self.viewShowed=YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:@"back" sender:self];
}
- (IBAction)takePicture:(id)sender {
    [self.imagePickerController takePicture];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.imageToSave = image;
    
    //    try printing metadata
    
    NSMutableDictionary *metadataDict = [info objectForKey:UIImagePickerControllerMediaMetadata];
    
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

    if (metadataDict) {
        NSLog(@"Below is everything in the metadata");
        for(NSString *key in [metadataDict allKeys]) {
            NSLog(@"%@:%@",key,[metadataDict objectForKey:key]);
        }
        NSLog(@"END Below is everything in the metadata");

        // Enable this when using handler. TODO: set context for testing existance of document.
//        self.managedObjectContext = self.document.managedObjectContext;

        Photo *photoManagedObject =  [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
        NSLog(@"Retrieve DateTimeOriginal as NSString: %@", [[metadataDict objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"]);
        photoManagedObject.takeDate=[NSDate date];
        NSLog(@"Before saving: %@",photoManagedObject.takeDate);
        
        
        // Actually we can read within the context before saving to the document.
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
            if (success) {
                NSLog(@"After saving: %@",photoManagedObject.takeDate);
            }
            else NSLog(@"Failed to Save.");
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:self.managedObjectContext];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(objectsDidChange:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:self.managedObjectContext];
        
        
//        NSLog(@"Stored");
////        NSLog([NSDate date]);
//        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
//        NSLog([formatter stringFromDate:[ photoManagedObject valueForKey:@"takeDate"]  ]);
//        NSLog([formatter stringFromDate:[NSDate date]]);
    }
    else {
        NSLog(@"Could not load metadata.");
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:((UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage]).CGImage
                                 metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              NSLog(@"Saved Picture at assetURL: %@", assetURL);
                          }];
//    UIImageWriteToSavedPhotosAlbum (self.imageToSave, self, @selector(image:didFinishSavingWithError:contextInfo:) , nil);
    self.captureMomentButton.hidden=NO;
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideWithAnimation) userInfo:nil repeats:NO];
}

- (void)objectsDidChange:(NSNotification *)notification
{
    NSLog(@"NSManagedObjects did change.");
}

- (void)contextDidSave:(NSNotification *)notification
{
    NSLog(@"NSManagedContext did save.");
}

- (void)hideWithAnimation {
    
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{self.captureMomentButton.hidden=YES;}
                     completion:NULL];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
