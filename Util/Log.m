//
//  Log.m
//  ChorusVC
//
//  Created by cyh on 13. 2. 21..
//  Copyright (c) 2013년 saeha. All rights reserved.
//

#import "Log.h"

static int gLogLevel = kLogTypeInfo;

@implementation Log

+ (void)pringLogPrefix:(NSString *)prefix message:(NSString *)msg, ... {

    va_list args;
    va_start(args, msg);
    
    NSString *log = [[NSString alloc] initWithFormat:msg arguments:args];
    NSLog(@"%@ : %@", prefix, log);
    
    [log release];
}


+ (void)setLogType:(LogType)logType {
    gLogLevel |= logType;
}

+ (void)info:(NSString *)message, ... {
    
    if ((gLogLevel & kLogTypeInfo) == NO)
        return;
    
    va_list args;
    va_start(args, message);
    
    NSString *log = [[NSString alloc] initWithFormat:message arguments:args];
    NSLog(@"###INFO.### : %@", log);
    
    [log release];
}

+ (void)error:(NSString *)message, ... {
    if ((gLogLevel & kLogTypeError) == NO)
        return;
    
    va_list args;
    va_start(args, message);
    
    NSString *log = [[NSString alloc] initWithFormat:message arguments:args];
    NSLog(@"###ERROR### : %@", log);
    
    [log release];
}

+ (void)debug:(NSString *)message, ... {

    if ((gLogLevel & kLogTypeInfo) == NO)
        return;

    va_list args;
    va_start(args, message);
    
    NSString *log = [[NSString alloc] initWithFormat:message arguments:args];
    NSLog(@"###DEBUG### : %@", log);
    
    [log release];
}

+ (void)printRect:(CGRect)rect withPrefix:(NSString *)prefix {
    NSLog(@"###RECT.### : %@ - [%0.f, %0.f, %0.f, %0.f]",
          prefix, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

+ (void)printPoint:(CGPoint)point withPrefix:(NSString *)prefix {
    NSLog(@"###POINT### : %@ - [%0.f, %0.f]", prefix, point.x, point.y);
}

+ (void)printSize:(CGSize)size withPrefix:(NSString *)prefix {
    NSLog(@"###SIZE.### : %@ - [%0.f, %0.f]", prefix, size.width, size.height);
}

@end
