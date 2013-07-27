//
//  KNStreamManager.m
//  StreamManagerTest
//
//  Created by cyh on 7/21/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#import "KNStreamManager.h"
#import "StreamManager.h"
#import <ifaddrs.h>
#import <arpa/inet.h>


static KNStreamManager* gInstance = nil;

@interface KNStreamManager () {
    
    uint8_t* videpStreamBuffer_;
    uint32_t videpStreamBufferSize_;
    StreamManager* stream_;
    
    void(^readFrameThreadStopBlock_)(void);
}
@property (assign, atomic) BOOL readFrameThreadStop;
@end

@implementation KNStreamManager

@synthesize readFrameThreadStop = _readFrameThreadStop;

+ (KNStreamManager *)sharedObject {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gInstance = [[KNStreamManager alloc] init];
    });
    return gInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        
        stream_ = new StreamManager();
    }
    return self;
}

- (void)openServerPort:(int)port acceptBlock:(void(^)(int clientAcceptResult))acceptBlock failBlock:(void(^)(void))failBlock {
    
    _readFrameThreadStop = NO;
    int ret = self->stream_->createServer(port);
    if (ret != 1 && failBlock) {
        _readFrameThreadStop = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            failBlock();
        });
        return;
    }
    
    ret = self->stream_->waitingClient();
    
    if (acceptBlock) {
        acceptBlock(ret);
    }
}

- (void)closeServer {
    self->stream_->closeServer();
}

- (void)connectServer:(NSString *)ip withPort:(int)port connectBlock:(void(^)(int connectResult))connectBlock {
    
    _readFrameThreadStop = NO;
    int ret = self->stream_->connectToServer([ip UTF8String], port);
    if (ret == -1) {
        _readFrameThreadStop = YES;
    }
        
    
    if (connectBlock) {
        connectBlock(ret);
    }
}

- (void)disconnectServer {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self->stream_->disconnect();
    });
}

- (void)setVideoRecieveBuffer {
    
    videpStreamBufferSize_ = 1280 * 720 >> 3;
    videpStreamBuffer_ = (uint8_t *)malloc(sizeof(uint8_t) * videpStreamBufferSize_);

    self->stream_->registerDecodeStream(STREAM_VIDEO, videpStreamBuffer_);
}

- (void)readFrameWithReadBlock:(void(^)(int streamid, uint8_t* buffer, int size))readBlock {
    
    if (videpStreamBuffer_ == NULL) {
        [self setVideoRecieveBuffer];
    }

    while (_readFrameThreadStop == NO) {
      
        int ret = self->stream_->readFrame();
        
        if (_readFrameThreadStop)
            break;
        
        //일단비디오만 처리
        switch (ret) {
            case STREAM_COMMAND:
                break;
                
            case STREAM_RESPONSE:
                break;

            case STREAM_VIDEO:
                if (readBlock) {
                    readBlock(ret,
                              (uint8_t *)self->stream_->decodeStream[ret]->buffer,
                              self->stream_->decodeStream[ret]->len);
                }
                self->stream_->decodeStream[ret]->reset();
                break;

            case STREAM_VOICE:
                break;
                
            case STREAM_AUDIO:
                break;

            case PACKET_NOT_FINISH:
                break;

            case PACKET_PARSE_ERROR:
                break;
                
            case SOCKET_DISCONNECT:
                break;
        }
        
        if (ret == SOCKET_DISCONNECT) {
            _readFrameThreadStop = YES;
        }
        
        if (_readFrameThreadStop)
            break;
        
    }
    
    if (readFrameThreadStopBlock_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            readFrameThreadStopBlock_();
            [readFrameThreadStopBlock_ release];
            readFrameThreadStopBlock_ = nil;
        });
    }
}

- (void)readFrameStopWithThreadStopBlock:(void(^)(void))threadStopBlock {
    
    if (_readFrameThreadStop) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            threadStopBlock();
        });
        

        if (readFrameThreadStopBlock_) {
            [readFrameThreadStopBlock_ release];
            readFrameThreadStopBlock_  = nil;
        }
        return;
    }
    
    if (readFrameThreadStopBlock_) {
        [readFrameThreadStopBlock_ release];
    }
    readFrameThreadStopBlock_ = [threadStopBlock copy];
    _readFrameThreadStop = YES;
}

- (int)writeFram:(uint8_t *)buffer size:(int)size {
    return self->stream_->writeVideoFrame(STREAM_VIDEO, buffer, size);
}

- (NSString *)getIPAddress
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself
                
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else
                    if([name isEqualToString:@"pdp_ip0"]) {
                        // Interface is the cell connection on the iPhone
                        cellAddress = addr;
                    }
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    return addr ? addr : @"0.0.0.0";
}


@end
