//
//  LogFile.m
//  iMultiviewUC
//
//  Created by YH CHOI on 12. 4. 25..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LogFile.h"

#define LOG_FILE_NAME       @"restDbgLog.txt"

@interface LogFile () {
    
    NSString* docPath_;
    NSString* logFilePath_;
    NSDateFormatter* timeStampFormatter_;
}
@end

    
@implementation LogFile

- (void)dealloc {
    
    if (docPath_) {
        [docPath_ release];
        docPath_ = nil;
    }
    
    if (logFilePath_) {
        [logFilePath_ release];
        logFilePath_ = nil;
    }
    
    if (timeStampFormatter_) {
        [timeStampFormatter_ release];
        timeStampFormatter_ = nil;
    }
    [super dealloc];
}

+ (LogFile *)sharedObject {
    
    static LogFile* instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[LogFile alloc] init];
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        instance->docPath_ = [[paths objectAtIndex:0] retain];
        
        instance->logFilePath_ = [[NSString stringWithFormat:@"%@/%@", instance->docPath_, LOG_FILE_NAME] retain];
        NSFileHandle* logFileHandle = [NSFileHandle fileHandleForWritingAtPath:instance->logFilePath_];
        
        if (nil == logFileHandle) {
            [[NSFileManager defaultManager] createFileAtPath:instance->logFilePath_ contents:nil attributes:nil];
        } else {
            [logFileHandle closeFile];
        }
        
        instance->timeStampFormatter_ = [[NSDateFormatter alloc] init];
        [instance->timeStampFormatter_ setDateFormat:@"yyyy:MM:dd HH:mm:ss:SSS"];
        
    });
    return instance;
}


- (void)wirteLog:(NSString *)log {
    
    [log retain];
    
    NSFileHandle* logFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:logFilePath_];    
    if (nil == logFileHandle) {
        NSLog(@"=========>>>>>>>>> %s File handle is nil.", __func__);
        [log release];
        return;
    }
    [logFileHandle seekToEndOfFile];
    
    NSDate* date        = [NSDate date];
    NSString* timeStamp = [timeStampFormatter_ stringFromDate:date];
    NSString* logMsg    = [NSString stringWithFormat:@"[%@]%@\r\n", timeStamp, log];
    NSData* logData     = [logMsg dataUsingEncoding:NSUTF8StringEncoding];
    
    [logFileHandle writeData:logData];
    [logFileHandle closeFile];
    
    [log release];    
}

- (void)sendLogWith:(NSString *)serverURL 
       withIdentity:(NSString *)identity
     withCompletion:(void (^)(NSString* htmlResult))completion {

    NSDate* date        = [NSDate date];
    NSString* timeStamp = [timeStampFormatter_ stringFromDate:date];


    NSData* logData = [NSData dataWithContentsOfFile:logFilePath_];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
               
        NSMutableURLRequest* request= [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:serverURL]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"text/html, application/xhtml+xml, */*" forHTTPHeaderField:@"Accept"];
        [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *postBody = [NSMutableData data];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@_%@.txt\"\"\r\n", timeStamp,identity] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:logData];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postBody];
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString* returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];

        if (completion)
            completion(returnString);
        
        [returnString release];
        
        [[NSFileManager defaultManager] removeItemAtPath:logFilePath_ error:nil];
    });
}
@end
