//
//  VideoViewController.m
//  KnVideoPhone
//
//  Created by cyh on 7/25/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#import "VideoViewController.h"
#import "KNStreamManager.h"
#import "MediaManager.h"
@interface VideoViewController () {
 
    uint8_t* videoRecvBuffer_;
    uint32_t videoRecvBufferSize_;
}
@end

@implementation VideoViewController

@synthesize naviBar         = _naviBar;
@synthesize viewPeer        = _viewPeer;
@synthesize viewPeerImage   = _viewPeerImage;
@synthesize viewPreview     = _viewPreview;
@synthesize lblMessage      = _lblMessage;

@synthesize streamMode      = _streamMode;

- (void)dealloc {
    [_naviBar release];
    [_viewPeer release];
    [_viewPeerImage release];
    [_viewPreview release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    videoRecvBufferSize_ = 1280 * 720 >> 3;
    videoRecvBuffer_ = (uint8_t *)malloc(sizeof(uint8_t) * videoRecvBufferSize_);

    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    
    int peerImageNum = (arc4random() % 3) + 1;
    NSString* peerImageName = [NSString stringWithFormat:@"basePeer%d.jpg", peerImageNum];
    _viewPeerImage.image = [UIImage imageNamed:peerImageName];
    
    NSLog(@"@StreamMode : %d, %d", _streamMode, peerImageNum);
    _lblMessage.text = [NSString stringWithFormat:@"@StreamMode : %@", _streamMode == 0 ? @"Server Mode" : @"Client Mode"];

    _naviBar.topItem.title = [[KNStreamManager sharedObject] getIPAddress];
    
    [[MediaManager sharedObject] setOrientation:kKNVideoOrientationPortrait];
    [[MediaManager sharedObject] videoCaptureStart:_viewPreview
                                        resolution:kKNCapture288
                                               fps:1
                                videoPacketizeMode:kKNPacketizeMode_Single_Nal
                                   appendRTPHeader:NO
                                       encodeBlock:^(uint8_t *encData, int size)
    {
        NSLog(@"enc len : %d", size);
    }];
    
    if (_streamMode == kKNStreamModeServer) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self runServerProcess];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self runeClientProcess];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)runServerProcess {
    
    void(^recvThread)(void) = ^(void) {
        
        KNStreamManager* sm = [KNStreamManager sharedObject];
        while (YES) {
            
        }
    };

    _lblMessage.text = [NSString stringWithFormat:@"@Server Start Port : %d", 6000];
    [[KNStreamManager sharedObject] setVideoRecieveBuffer:videoRecvBuffer_ size:videoRecvBufferSize_];
    [[KNStreamManager sharedObject] openServerPort:6000 acceptBlock:^(int clientAcceptResult) {
        NSLog(@"Client Accept OK");
        [_lblMessage performSelectorOnMainThread:@selector(setText:)
                                      withObject:@"@Client Accept OK"
                                   waitUntilDone:NO];
        
        [[KNStreamManager sharedObject] sendConnectCommand];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            recvThread();
        });
    }];
}

- (void)runeClientProcess {
    
}

- (IBAction)exit:(id)sender {
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    _lblMessage.text = @"@Will disconnect.";
    
    [[MediaManager sharedObject] videoCaptureStop];
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (_streamMode == kKNStreamModeServer) {
            [[KNStreamManager sharedObject] closeServer];
        } else {
            [[KNStreamManager sharedObject] disconnectServer];
        }
    }];
}

@end
