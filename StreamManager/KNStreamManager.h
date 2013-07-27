//
//  KNStreamManager.h
//  StreamManagerTest
//
//  Created by cyh on 7/21/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNStreamManager : NSObject

+ (KNStreamManager *)sharedObject;

- (NSString *)getIPAddress;

- (void)openServerPort:(int)port acceptBlock:(void(^)(int clientAcceptResult))acceptBlock failBlock:(void(^)(void))failBlock;
- (void)closeServer;

- (void)connectServer:(NSString *)ip withPort:(int)port connectBlock:(void(^)(int connectResult))connectBlock;
- (void)disconnectServer;

- (void)setVideoRecieveBuffer;

- (void)readFrameWithReadBlock:(void(^)(int streamid, uint8_t* buffer, int size))readBlock;
- (void)readFrameStopWithThreadStopBlock:(void(^)(void))threadStopBlock;
- (int)writeFram:(uint8_t *)buffer size:(int)size;
@end
