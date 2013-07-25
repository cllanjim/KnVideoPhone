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
    StreamManager* stream_;
}
@end

@implementation KNStreamManager


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

- (void)openServerPort:(int)port acceptBlock:(void(^)(int clientAcceptResult))acceptBlock {
    self->stream_->createServer(port);
    int ret = self->stream_->waitingClient();
    
    if (acceptBlock) {
        acceptBlock(ret);
    }
}

- (void)closeServer {
    self->stream_->closeServer();
}

- (void)connectServer:(NSString *)ip withPort:(int)port connectBlock:(void(^)(int connectResult))connectBlock {
    int ret = self->stream_->connectToServer([ip UTF8String], port);
    
    if (connectBlock) {
        connectBlock(ret);
    }
}

- (void)disconnectServer {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self->stream_->disconnect();
    });
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
