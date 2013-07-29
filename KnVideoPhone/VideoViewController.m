//
//  VideoViewController.m
//  KnVideoPhone
//
//  Created by cyh on 7/25/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#import "VideoViewController.h"
#import "KNStreamManager.h"
#import "SettingManager.h"
#import "AlertManager.h"
#import "MediaVideoParam.h"
#import "MediaAudioParam.h"
#import "MediaManager2.h"
#import "Global.h"

#define TEST_LOOPBACK_PLAY          0

@interface VideoViewController ()
@property (assign, atomic) BOOL sendVideoFrame;
- (void)startVideoCapture2;
- (void)startAudioCapture;
- (void)startStream;
@end

@implementation VideoViewController

@synthesize naviBar         = _naviBar;
@synthesize viewPeer        = _viewPeer;
@synthesize viewPeerImage   = _viewPeerImage;
@synthesize viewPreview     = _viewPreview;
@synthesize streamMode      = _streamMode;
@synthesize sendVideoFrame  = _sendVideoFrame;

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
    
    _sendVideoFrame = NO;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    int peerImageNum = (arc4random() % 3) + 1;
    NSString* peerImageName = [NSString stringWithFormat:@"basePeer%d.jpg", peerImageNum];
    _viewPeerImage.image = [UIImage imageNamed:peerImageName];
    
    NSLog(@"@StreamMode : %d, %d", _streamMode, peerImageNum);
    _naviBar.topItem.title = [[KNStreamManager sharedObject] getIPAddress];

#if TEST_LOOPBACK_PLAY == 0
    [self startStream];
#endif
    [self startVideoCapture2];
    [self startAudioCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)startVideoCapture2 {
    
    NSInteger captureFPS = [[SettingManager sharedObject] getCaptureFPS];
    NSInteger captureResolution = [[SettingManager sharedObject] getCaptureResolution];
    
    KNCaptureResolution resolution = kKNCaptureLow;
    switch (captureResolution) {
        case 144:
            resolution = kKNCaptureLow;
            break;
        case 288:
            resolution = kKNCapture288;
            break;
        case 480:
            resolution = kKNCapture480;
            break;
    }

    KNVideoType videType = [[SettingManager sharedObject] getVideoCodec] == 0 ? kKNVideoH264 : kKNVideoVP8;
    
    MediaVideoParam* param = [[MediaVideoParam alloc] init];
    param.viewPreview = _viewPreview;
    param.viewPeerview = _viewPeer;
    param.encVideoCodec = param.decVideoCodec = videType;
    param.captureResolution = resolution;
    param.captureFPS = captureFPS;
    param.captureOrientation = kKNVideoOrientationPortrait;
    param.packetizeMode = kKNPacketizeMode_Single_Nal;
    param.appendRtpHeader = NO;

    [param setEncOuputBlock:^(uint8_t *encBuffer, int size) {

#if TEST_LOOPBACK_PLAY == 0
        if (_sendVideoFrame) {
            [[KNStreamManager sharedObject] writeFram:2 buffer:encBuffer size:size];
        }
#else
        [[MediaManager2 sharedObject] decodeVideoWithEncData:encBuffer size:size];
#endif
    }];
    
    [[MediaManager2 sharedObject] startVideoWithParam:param];
    [param release];
}

- (void)startAudioCapture {
    
    MediaAudioParam* ap = [[MediaAudioParam alloc] init];
    ap.encAudioCodec = ap.decAudioCodec = kKNAudioSpeex;
    ap.speexQuality = 8;
    ap.samplerate = kSamplerate16k;
    ap.appendRtpHeader = NO;
    
    [ap  setEncodeBlock:^(uint8_t *encBuffer, int size) {
#if TEST_LOOPBACK_PLAY == 0
        if (_sendVideoFrame) {
            [[KNStreamManager sharedObject] writeFram:3 buffer:encBuffer size:size];
        }
#else
        [[MediaManager2 sharedObject] decodeAudioWithEncData:pcm size:size];
#endif
    }];
    
    [[MediaManager2 sharedObject] startAudioWithParam:ap];
    [ap release];
    
    
}

- (void)startStream {

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

- (void)recvThread {
    
    NSLog(@"@@@@@@@@START Recv");

    _sendVideoFrame = YES;
    [[KNStreamManager sharedObject] readFrameWithReadBlock:^(int streamid, uint8_t *buffer, int size) {
        
        if (streamid == 2) {
            [[MediaManager2 sharedObject] decodeVideoWithEncData:buffer size:size];
            return;
        }

        
        if (streamid == 3) {
            [[MediaManager2 sharedObject] decodeAudioWithEncData:buffer size:size];
            return;
        }
    }];
    NSLog(@"@@@@@@@@END Recv");
}

- (void)runServerProcess {
    
    [[KNStreamManager sharedObject] openServerPort:6000 acceptBlock:^(int clientAcceptResult) {        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self recvThread];
        });
    } failBlock:^{
        
        [[AlertManager sharedObject] showAlertWithTitle:@"서버열기 실패"
                                                message:@"서버열기 실패. 잠시후 다시혀~\n(너무빨리하면 소켓 지대로 안닫히는듯..)"
                                           singleButton:@"확인"
                                      singleButtonBlock:^
         {
             [self performSelectorOnMainThread:@selector(exit:)
                                    withObject:nil
                                 waitUntilDone:NO];
         }];
    }];
}

- (void)runeClientProcess {
    
    NSString* ip = [[SettingManager sharedObject] getServerIP];
    NSInteger port = [[SettingManager sharedObject] getServerPort];
    [[KNStreamManager sharedObject] connectServer:ip withPort:port connectBlock:^(int connectResult) {
        
        if (connectResult == -1) {
            
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                NSString* message = [NSString stringWithFormat:@"연결정보 %@:%d", ip, port];
                [[AlertManager sharedObject] showAlertWithTitle:@"연결실패"
                                                        message:message
                                                   singleButton:@"확인"
                                              singleButtonBlock:^
                 {
                     
                     [self performSelectorOnMainThread:@selector(exit:)
                                            withObject:nil
                                         waitUntilDone:NO];
                 }];
            });
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self recvThread];
        });
    }];
}

- (IBAction)exit:(id)sender {
    
    [[AlertManager sharedObject] showAlertWithTitle:@"통화종료" message:@"통화종료?" cancelTitle:@"취소" confirmTitle:@"종료" cancelBlack:nil
                                       confirmBlock:^{
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        _sendVideoFrame = NO;
        [[MediaManager2 sharedObject] stopVideo];
        
        if (_streamMode == kKNStreamModeServer) {
            [[KNStreamManager sharedObject] closeServer];
        } else {
            [[KNStreamManager sharedObject] disconnectServer];
        }
        
        [[KNStreamManager sharedObject] readFrameStopWithThreadStopBlock:^{
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }];
}

@end
