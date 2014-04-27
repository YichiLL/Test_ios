//
//  PictureViewController.m
//  Test
//
//  Created by Y. Liu on 4/21/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "PictureViewController.h"
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface PictureViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UIImage *fullScreenImage;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

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
    self.imageView.image = self.fullScreenImage;
    self.scrollView.contentSize = self.imageView.bounds.size;
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