//
//  CaptureMomentViewController.m
//  Test
//
//  Created by Y. Liu on 3/24/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "CaptureMomentViewController.h"

@interface CaptureMomentViewController ()

@end

@implementation CaptureMomentViewController

#pragma mark - Life cycle

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"CaptureMoment - viewWillAppear");
    [super viewWillAppear:animated];

    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Capture the Moment";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Reading tags

- (IBAction)happyButtonPressed:(id)sender {
    self.photo.tag=@"Happy";
}
- (IBAction)funButtonPressed:(id)sender {
    self.photo.tag=@"Fun";
}

#pragma mark - Going back actions

- (IBAction)cancelButton:(id)sender
{
    [self goBackToCamera];
}
- (IBAction)okButton:(id)sender
{
    [self goBackToCamera];
}

- (void) goBackToCamera
{
    [[self.navigationController popViewControllerAnimated:YES] viewWillAppear:YES];
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
