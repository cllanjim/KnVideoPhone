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

- (void)dealloc {

    [_lblIPAddress release];
    [_tfIPAddress release];
    [_tfPort release];
    [_btnStartServer release];
    [_btnConnectServer release];

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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}



- (void)showVideoViewWithStreamMode:(KNStreamMode)streamMode {
    
    [[SettingManager sharedObject] setServerIP:_tfIPAddress.text];
    [[SettingManager sharedObject] setServerPort:[_tfPort.text integerValue]];
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
    
    NSString* ip = _tfIPAddress.text;
    NSInteger port = [_tfPort.text integerValue];
    [[KNStreamManager sharedObject] connectServer:ip withPort:port connectBlock:^(int connectResult) {
        [self showVideoViewWithStreamMode:kKNStreamModeClient];
    }];
}

#pragma mark - UITouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_tfIPAddress resignFirstResponder];
    [_tfPort resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
