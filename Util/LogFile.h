//
//  LogFile.h
//  iMultiviewUC
//
//  Created by YH CHOI on 12. 4. 25..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogFile : NSObject 

+ (LogFile *)sharedObject;

- (void)wirteLog:(NSString *)log;

- (void)sendLogWith:(NSString *)serverURL 
       withIdentity:(NSString *)identity
     withCompletion:(void (^)(NSString* htmlResult))completion;
@end
