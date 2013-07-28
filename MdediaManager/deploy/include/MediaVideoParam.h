//
//  MeidaManagerParam.h
//  MediaManager
//
//  Created by cyh on 7/27/13.
//  Copyright (c) 2013 SH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Global.h"

typedef void(^blockEncOutput)(uint8_t* encBuffer, int size);

@interface MediaVideoParam : NSObject

@property (retain, nonatomic) UIView* viewPreview;
@property (assign, nonatomic) KNVideoType videoCodec;
@property (assign, nonatomic) KNCaptureResolution captureResolution;
@property (assign, nonatomic) KNVideoVideoOrientation captureOrientation;
@property (assign, nonatomic) NSInteger captureFPS;
@property (assign, nonatomic) KNVideoPacketizeMode packetizeMode;
@property (assign, nonatomic) BOOL appendRtpHeader;

/**
    인코딩된 데이터를 받을 블록.
 */
- (void)setEncOuputBlock:(blockEncOutput)encOut;

- (blockEncOutput)getEncOuputBlock;

- (CGSize)getCaptureSize;



@end
