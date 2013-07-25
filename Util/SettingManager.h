//
//  SettingManager.h
//  MultiviewMobile
//
//  Created by cyh on 7/16/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalDefine.h"

@interface SettingManager : NSObject
+ (SettingManager *)sharedObject;

- (void)checkVersion:(NSString *)ver completion:(void(^)(BOOL isUpdate))completion;
- (void)save;

- (void)setAppVersion:(NSString *)ver;
- (NSString *)getAppVersion;

- (void)setServerIP:(NSString *)ip;
- (NSString *)getServerIP;

- (void)setServerPort:(NSInteger)port;
- (NSInteger)getServerPort;

@end
