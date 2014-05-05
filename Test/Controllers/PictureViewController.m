//
//  PictureViewController.m
//  Test
//
//  Created by Y. Liu on 4/21/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "PictureViewController.h"
#import "CBAutoScrollLabel.h"
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface PictureViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UIImage *fullScreenImage;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
//@property (weak, nonatomic) IBOutlet UITextField *tagTextField;
@property (weak, nonatomic) IBOutlet UITextField *weatherTextField;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextView *diaryLabel;




@end

#pragma mark -

@implementation PictureViewController

#pragma mark - Getters/Setters

- (UITapGestureRecognizer *)doubleTapGestureRecognizer
{
    if (!_doubleTapGestureRecognizer)
    {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    
    return _doubleTapGestureRecognizer;
}

- (void)setPhotoAsset:(ALAsset *)photoAsset
{
    _photoAsset = photoAsset;
    ALAssetRepresentation *assetRepresentation = self.photoAsset.defaultRepresentation;
    _fullScreenImage = [UIImage imageWithCGImage:assetRepresentation.fullResolutionImage scale:assetRepresentation.scale orientation:(UIImageOrientation)assetRepresentation.orientation];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tagLabel.text = self.photoManagedDocumentObject.tag;
    self.tagLabel.textColor = [UIColor blueColor];
    self.tagLabel.labelSpacing = 35; // distance between start and end labels
    self.tagLabel.pauseInterval = 1.7; // seconds of pause before scrolling starts again
    self.tagLabel.scrollSpeed = 30; // pixels per second
    self.tagLabel.textAlignment = NSTextAlignmentLeft; // centers text when no auto-scrolling is applied
    self.tagLabel.fadeLength = 12.f;
    self.tagLabel.scrollDirection = CBAutoScrollDirectionLeft;
    [self.tagLabel observeApplicationNotifications];
    self.imageView.image = self.fullScreenImage;
    //self.tagTextField.text=self.tag;
    self.diaryLabel.editable = false;
    self.diaryLabel.text = self.photoManagedDocumentObject.notes;
    self.weatherTextField.text = self.photoManagedDocumentObject.weatherDescription;
    self.scrollView.contentSize = self.imageView.bounds.size;
    
    NSDate *myDate = self.photoManagedDocumentObject.takeDateUTC;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    //[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *myDateString = [dateFormatter stringFromDate:myDate];
    NSLog(@"%@", myDateString);
    self.dateLabel.text = myDateString;
    
    NSString *address = self.photoManagedDocumentObject.addressFull;
    //NSString *newReplacedString = [address stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
    NSString *newReplacedString = [address stringByReplacingOccurrencesOfString:@"\n" withString:@" "];;
    
    self.locationLabel.text = newReplacedString;
    self.locationLabel.textColor = [UIColor blackColor];
    self.locationLabel.labelSpacing = 35; // distance between start and end labels
    self.locationLabel.pauseInterval = 1.7; // seconds of pause before scrolling starts again
    self.locationLabel.scrollSpeed = 30; // pixels per second
    self.locationLabel.textAlignment = NSTextAlignmentLeft; // centers text when no auto-scrolling is applied
    self.locationLabel.fadeLength = 12.f;
    self.locationLabel.scrollDirection = CBAutoScrollDirectionLeft;

    
//    self.dateLabel.text = self.photoManagedDocumentObject.takeDateUTC;
    [self.scrollView addGestureRecognizer:self.doubleTapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;

    if (self.photoAsset) // if there is no picture the calculation cause NaN in a layer
    {
        [self resizeImageViewToFitImage];
        [self centerImageView]; //Center Image only works in viewDidAppear, but as soon as you zoom, you can't go back to the initial view where entire image shows in the imageview
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.fullScreenImage = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = TRUE;
}

#pragma mark - Gestures

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (self.scrollView.zoomScale > 1.0f)
    {
        [self.scrollView setZoomScale:1.0f animated:YES];
        return;
    }
    
    [self.scrollView setZoomScale:3.0f animated:YES];
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerImageView];
}

#pragma mark UIScrollView Helpers

- (void)resizeImageViewToFitImage
{
    CGFloat scale = 0.0f;
    CGFloat width = self.imageView.image.size.width;
    CGFloat height = self.imageView.image.size.height;
    
    CGRect frame = self.imageView.frame;
    
    if (width > height)
    {
        scale = width / height;
        frame.size.width = CGRectGetWidth(self.scrollView.bounds);
        frame.size.height = frame.size.width / scale;
    }
    else
    {
        scale = height / width;
        frame.size.height = CGRectGetHeight(self.scrollView.bounds);
        frame.size.width = frame.size.height / scale;
    }
    
    self.imageView.frame = frame;
}

- (void)centerImageView
{
    CGRect scrollBounds = self.scrollView.bounds;
    CGRect imageViewFrame = self.imageView.frame;
    
    if (CGRectGetWidth(imageViewFrame) < CGRectGetWidth(scrollBounds))
        imageViewFrame.origin.x = (CGRectGetWidth(scrollBounds) - CGRectGetWidth(imageViewFrame)) / 2;
    else
        imageViewFrame.origin.x = 0.0f;
    
    if (CGRectGetHeight(imageViewFrame) < CGRectGetHeight(scrollBounds))
        imageViewFrame.origin.y = (CGRectGetHeight(scrollBounds) - CGRectGetHeight(imageViewFrame)) / 2;
    else
        imageViewFrame.origin.y = 0.0f;
    
    self.imageView.frame = imageViewFrame;
}

@end