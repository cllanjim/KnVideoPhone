//
//  Log.h
//  ChorusVC
//
//  Created by cyh on 13. 2. 21..
//  Copyright (c) 2013년 saeha. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kLogTypeInfo    = 0x2,
    kLogTypeError   = 0x4,
    kLogTypeDebug   = 0x8
}LogType;

@interface Log : NSObject

+ (void)setLogType:(LogType)logType;

+ (void)info:(NSString *)message, ...;
+ (void)error:(NSString *)message, ...;
+ (void)debug:(NSString *)message, ...;

+ (void)printRect:(CGRect)rect withPrefix:(NSString *)prefix;
+ (void)printPoint:(CGPoint)point withPrefix:(NSString *)prefix;
+ (void)printSize:(CGSize)size withPrefix:(NSString *)prefix;
@end
