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

- (void)openServerPort:(int)port acceptBlock:(void(^)(int clientAcceptResult))acceptBlock;
- (void)closeServer;

- (void)connectServer:(NSString *)ip withPort:(int)port connectBlock:(void(^)(int connectResult))connectBlock;
- (void)disconnectServer;

- (void)setVideoRecieveBuffer:(uint8_t *)buffer size:(int)size;
- (void)sendConnectCommand;
@end
