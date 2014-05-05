//
//  CaptureMomentViewController.m
//  Test
//
//  Created by Y. Liu on 3/24/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "CaptureMomentViewController.h"

@interface CaptureMomentViewController () <UITextViewDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (strong,nonatomic) AVAudioRecorder *recorder;
@property (strong,nonatomic) AVAudioPlayer *player;
@property (weak,nonatomic) NSURL *audioFileURL;

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;


@end

@implementation CaptureMomentViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addDoneToolBarToKeyboard:self.notesTextView];
    [self setupRecordSession];
}

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"CaptureMoment - viewWillAppear");
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    self.navigationItem.title = @"Capture the Moment";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
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
- (IBAction)tagButtonPressed:(id)sender {
    UIButton *tagButton = (UIButton*)sender;
    if (!self.photo.tag){
        self.photo.tag=[NSString stringWithFormat:@"#%@",tagButton.titleLabel.text];}
    else {
        self.photo.tag = [NSString stringWithFormat:@"%@ #%@", self.photo.tag, tagButton.titleLabel.text];}
    tagButton.enabled=false;
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
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Recording
- (void) setupRecordSession{
    // Disable Stop/Play button when application launches
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:NO];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-mm-dd-HH-mm-ss"];
    NSDate *todaysDate;
    todaysDate = [NSDate date];
    NSString *dateString =[formatter stringFromDate:self.photo.takeDateUTC];
    
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],[NSString stringWithFormat:@"%@%@", dateString, @".m4a"], nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    // FAILED trying to save to managed document
    //    NSURL *outputFileURL = [self.managedDocument.fileURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", dateString, @".m4a"]];
    //    NSLog(@"document url %@",self.managedDocument.fileURL );
    //    NSLog(@"Appending %@",[NSString stringWithFormat:@"%@%@", dateString, @".m4a"]);
    //    NSLog(@"fileURL is %@",outputFileURL);
    self.audioFileURL = outputFileURL;
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    
}

- (IBAction)recordPauseTapped:(id)sender {
    // Stop the audio player before recording
    if (self.player.playing) {
        [self.player stop];
    }
    
    if (!self.recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [self.recorder record];
        self.recordPauseButton.selected=true;
        
    } else {
        
        // Pause recording
        [self.recorder pause];
        self.recordPauseButton.selected=false;
        
    }
    
    [self.stopButton setEnabled:YES];
    [self.playButton setEnabled:NO];
    
}
- (IBAction)stopTapped:(id)sender {
    self.recordPauseButton.selected=false;
    [self.recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}
- (IBAction)playTapped:(id)sender {
    if (!self.recorder.recording){
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
        [self.player setDelegate:self];
        [self.player play];
    }
}
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    self.photo.audioURL = [self.audioFileURL absoluteString];
    self.recordPauseButton.selected=false;
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:YES];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    // additional function after playing ends
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
