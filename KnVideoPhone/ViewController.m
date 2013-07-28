//
//  ViewController.m
//  KnVideoPhone
//
//  Created by cyh on 7/24/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#import "ViewController.h"
#import "KNStreamManager.h"
#import "UIDevice+Target.h"
#import "CustomSegue.h"
#import "VideoViewController.h"
#import "SettingManager.h"

@interface ViewController ()
@end

@implementation ViewController

@synthesize lblIPAddress        = _lblIPAddress;
@synthesize tfIPAddress         = _tfIPAddress;
@synthesize tfPort              = _tfPort;
@synthesize btnStartServer      = _btnStartServer;
@synthesize btnConnectServer    = _btnConnectServer;
@synthesize tfCaptureFPS        = _tfCaptureFPS;
@synthesize segResolution       = _segResolution;
@synthesize segVideoCodec       = _segVideoCodec;

- (void)dealloc {

    [_lblIPAddress release];
    [_tfIPAddress release];
    [_tfPort release];
    [_btnStartServer release];
    [_btnConnectServer release];
    [_tfCaptureFPS release];
    [_segResolution release];
    [_segVideoCodec release];

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _lblIPAddress.text = [[KNStreamManager sharedObject] getIPAddress];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"MemoryWarning  %s", __func__);
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _tfIPAddress.text = [[SettingManager sharedObject] getServerIP];
    _tfPort.text = [NSString stringWithFormat:@"%d", [[SettingManager sharedObject] getServerPort]];
    _tfCaptureFPS.text = [NSString stringWithFormat:@"%d", [[SettingManager sharedObject] getCaptureFPS]];
    
    NSInteger resolution = [[SettingManager sharedObject] getCaptureResolution];
    int selected = 0;
    switch (resolution) {
        case 144:
            selected = 0;
            break;
        case 288:
            selected = 1;
            break;
        case 480:
            selected = 2;
            break;
    }
    [_segResolution setSelectedSegmentIndex:selected];
    [_segVideoCodec setSelectedSegmentIndex:[[SettingManager sharedObject] getVideoCodec]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}



- (void)showVideoViewWithStreamMode:(KNStreamMode)streamMode {
    
    [[SettingManager sharedObject] setServerIP:_tfIPAddress.text];
    [[SettingManager sharedObject] setServerPort:[_tfPort.text integerValue]];
    
    NSInteger fps = [_tfCaptureFPS.text integerValue];
    if (fps <= 0)
        fps = 1;
    if (fps > 30)
        fps = 30;
    _tfCaptureFPS.text = [NSString stringWithFormat:@"%d", fps];
    [[SettingManager sharedObject] setCaptureFPS:fps];
    
    NSInteger resolution = 288;
    int selected = _segResolution.selectedSegmentIndex;
    switch (selected) {
        case 0:
            resolution = 144;
            break;
        case 1:
            resolution = 288;
            break;
        case 2:
            resolution = 480;
            break;
    }
    [[SettingManager sharedObject] setCaptureResolution:resolution];
    [[SettingManager sharedObject] setVideoCodec:_segVideoCodec.selectedSegmentIndex];
    
    [[SettingManager sharedObject] save];
    
    [_tfIPAddress resignFirstResponder];
    [_tfPort resignFirstResponder];
    
    BOOL isIPad = [UIDevice isIPad];
    NSString* storyBoardName = @"MainStoryboard_iPad";
    if (isIPad == NO) {
        storyBoardName = @"MainStoryboard_iPhone";
    }
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:storyBoardName bundle:[NSBundle mainBundle]];
    id dst = [sb instantiateViewControllerWithIdentifier:@"VideoViewController"];
    VideoViewController* vw = (VideoViewController *)dst;
    vw.streamMode = streamMode;
    CustomSegue* segue = [[CustomSegue alloc] initWithIdentifier:@"videosegue" source:self destination:dst];
    [segue perform];
    [segue autorelease];
}

- (IBAction)startServer:(id)sender {
    [self showVideoViewWithStreamMode:kKNStreamModeServer];
}

- (IBAction)connectToServer:(id)sender {    
    [self showVideoViewWithStreamMode:kKNStreamModeClient];
}

#pragma mark - UITouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_tfIPAddress resignFirstResponder];
    [_tfPort resignFirstResponder];
    [_tfCaptureFPS resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
