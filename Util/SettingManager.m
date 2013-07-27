//
//  SettingManager.m
//  MultiviewMobile
//
//  Created by cyh on 7/16/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#import "SettingManager.h"

static SettingManager* gInstance = nil;

#define kPropKeySettingMgrVersion       @"settingManagerVersion"
#define kPropKeyAppVersion              @"appVersion"
#define kPropKeyServerIP                @"serverIP"
#define kPropKeyServerPort              @"serverPort"
#define kPropKeyCaptureFPS              @"captureFPS"
#define kPropKeyCaptureResolution       @"caprureResolution"


#define SETTINGS    [NSUserDefaults standardUserDefaults]

@interface SettingManager ()
@property (assign) BOOL isIPad;
@end

@implementation SettingManager

@synthesize isIPad = _isIPad;

+ (SettingManager *)sharedObject {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gInstance = [[SettingManager alloc] init];
    });
    return gInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        UIUserInterfaceIdiom idom = [[UIDevice currentDevice] userInterfaceIdiom];
        _isIPad = (idom == UIUserInterfaceIdiomPad);
    }
    return self;
}

- (void)checkVersion:(NSString *)ver completion:(void(^)(BOOL isUpdate))completion {
    
    NSString* oldVersion = [self getPropertyVersion];
    NSLog(@"@@NSUserDefaults Version : %@", oldVersion);
    if ([oldVersion isEqualToString:ver] == NO) {
        NSLog(@"@@NSUserDefaults Version Changed.");
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        if (completion)
            completion(YES);
    }
    
    if (completion)
        completion(NO);
}

- (void)save {
    [SETTINGS synchronize];
}


- (NSString *)getPropertyVersion {
    
    id obj = [SETTINGS objectForKey:kPropKeySettingMgrVersion];
    if (obj == nil)
        [SETTINGS setObject:SETTING_MANAGER_VERSION forKey:kPropKeySettingMgrVersion];
    
    return [SETTINGS objectForKey:kPropKeySettingMgrVersion];
}


- (NSString *)getAppVersion {
    
    id obj = [SETTINGS objectForKey:kPropKeyAppVersion];
    if (obj == nil)
        [SETTINGS setObject:APP_VERSION forKey:kPropKeyAppVersion];
    
    return [SETTINGS objectForKey:kPropKeyAppVersion];
}


- (void)setAppVersion:(NSString *)ver {
    [SETTINGS setObject:kPropKeyAppVersion forKey:ver];
}


- (void)setServerIP:(NSString *)ip {
    [SETTINGS setObject:ip forKey:kPropKeyServerIP];
}

- (NSString *)getServerIP {

    id obj = [SETTINGS objectForKey:kPropKeyServerIP];
    if (obj == nil)
        [SETTINGS setObject:@"127.0.0.1" forKey:kPropKeyServerIP];
    
    return [SETTINGS objectForKey:kPropKeyServerIP];
}

- (void)setServerPort:(NSInteger)port {
    [SETTINGS setInteger:port forKey:kPropKeyServerPort];
}

- (NSInteger)getServerPort {
    
    id obj = [SETTINGS objectForKey:kPropKeyServerPort];
    if (obj == nil)
        [SETTINGS setInteger:6000 forKey:kPropKeyServerPort];
    
    return [SETTINGS integerForKey:kPropKeyServerPort];
}

- (void)setCaptureFPS:(NSInteger)fps {
    [SETTINGS setInteger:fps forKey:kPropKeyCaptureFPS];
}

- (NSInteger)getCaptureFPS {

    id obj = [SETTINGS objectForKey:kPropKeyCaptureFPS];
    if (obj == nil)
        [SETTINGS setInteger:DEFAULT_CAPTURE_FPS forKey:kPropKeyCaptureFPS];
    
    return [SETTINGS integerForKey:kPropKeyCaptureFPS];
}

- (void)setCaptureResolution:(NSInteger)resolutionHeigh {
    [SETTINGS setInteger:resolutionHeigh forKey:kPropKeyCaptureResolution];
}

- (NSInteger)getCaptureResolution {

    id obj = [SETTINGS objectForKey:kPropKeyCaptureResolution];
    if (obj == nil)
        [SETTINGS setInteger:DEFAULT_CAPTURE_HEIGHT forKey:kPropKeyCaptureResolution];
    
    return [SETTINGS integerForKey:kPropKeyCaptureResolution];
}

@end
