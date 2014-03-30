//
//  YCLCamViewController.m
//  Test
//
//  Created by Y. Liu on 3/24/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "YCLCamViewController.h"

@interface YCLCamViewController ()
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic,weak) UIImage *imageToSave;

@property (weak, nonatomic) IBOutlet UIButton *captureMomentButton;

@property (nonatomic) BOOL viewShowed;
@end

@implementation YCLCamViewController

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

    if (!self.viewShowed) {
        NSLog(@"actual show");
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        
        imagePickerController.showsCameraControls = NO;
        
        [[NSBundle mainBundle] loadNibNamed:@"SubView" owner:self options:nil];
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
    [self finishAndUpdate];
}

- (void)finishAndUpdate
{
    UIImageWriteToSavedPhotosAlbum (self.imageToSave, nil, nil , nil);
    self.captureMomentButton.hidden=NO;
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideWithAnimation) userInfo:nil repeats:NO];
    NSLog(@"Image Saved!");    
}

- (void)hideWithAnimation {
    
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{self.captureMomentButton.hidden=YES;}
                     completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
