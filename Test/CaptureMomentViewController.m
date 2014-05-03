//
//  CaptureMomentViewController.m
//  Test
//
//  Created by Y. Liu on 3/24/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "CaptureMomentViewController.h"

@interface CaptureMomentViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

@end

@implementation CaptureMomentViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addDoneToolBarToKeyboard:self.notesTextView];
}

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
    [self persistChanges];
}

- (void)addDoneToolBarToKeyboard:(UITextView *)textView
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)],
                         nil];
    [doneToolbar sizeToFit];
    textView.inputAccessoryView = doneToolbar;
}

- (void)doneButtonClickedDismissKeyboard
{
    [self.notesTextView resignFirstResponder];
}

- (void)persistChanges
{
    //Save notes but do not save default string
    if (![self.notesTextView.text isEqualToString:NOTE_HELP_TEXT]) {
        self.photo.notes = self.notesTextView.text;
    }
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

#pragma mark - UITextViewDelegate
static NSString *NOTE_HELP_TEXT = @"Write down how you are feeling, #create_a_tag, #tag2, and record audio memo below...";

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.notesTextView) {
        if ([textView.text isEqualToString:NOTE_HELP_TEXT]) {
            textView.text = @"";
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == self.notesTextView) {
        if ([textView.text length] == 0) {
            textView.text = NOTE_HELP_TEXT;
        }
    }
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
