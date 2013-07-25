//
//  AlertManager.m
//  iMultiviewUC
//
//  Created by YH CHOI on 12. 2. 9..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlertManager.h"
#import "Log.h"

@interface AlertManager () {
    
    UIAlertView* alert;
    BOOL hideWithoutAction;
    
    void (^cancelBlock) (void);
    void (^confirmBlock) (void);
    void (^optionBlock) (void);
    void (^textFieldBlock) (NSString* text);
    
    ALERT_TYPE alertType_;
    
    UITextField* tfText_;

}
@end

@implementation AlertManager

- (void)dealloc {
    [super dealloc];
}


+ (AlertManager *)sharedObject {
    
    static AlertManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AlertManager alloc] init];
    });
    return instance;
}

#pragma mark - Public
- (void)showAlertWithTitle:(NSString*)title 
                   message:(NSString *)msg 
               cancelTitle:(NSString *)cancelTitle
              confirmTitle:(NSString *)confirmTitle
               cancelBlack:(void(^)(void))cancel 
              confirmBlock:(void(^)(void))confirm {
    
    alertType_ = kAlertTypeBlock;
    
    confirmBlock = [confirm copy];
    cancelBlock = [cancel copy];
    
    [self hideCurrentAlert];
    
    self->alert = [[UIAlertView alloc] initWithTitle:title message:msg 
                                            delegate:self
                                   cancelButtonTitle:cancelTitle
                                   otherButtonTitles:confirmTitle, nil];
    [self->alert show];
}

- (void)showAlertWithTitle:(NSString*)title
                   message:(NSString *)msg
               cancelTitle:(NSString *)cancelTitle
              confirmTitle:(NSString *)confirmTitle
               optionTitle:(NSString *)opionTitle
               cancelBlack:(void(^)(void))cancel
              confirmBlock:(void(^)(void))confirm
               optionBlock:(void(^)(void))option {
    
    alertType_ = kAlertTypeBlock;
    
    confirmBlock    = [confirm copy];
    cancelBlock     = [cancel copy];
    optionBlock     = [option copy];
    
    [self hideCurrentAlert];
    
    self->alert = [[UIAlertView alloc] initWithTitle:title
                                             message:msg
                                            delegate:self
                                   cancelButtonTitle:cancelTitle
                                   otherButtonTitles:confirmTitle, opionTitle, nil];
    
    [self->alert show];
}


- (void)showAlertWithTitle:(NSString*)title 
                   message:(NSString *)msg 
              singleButton:(NSString *)singleButtonTitle
         singleButtonBlock:(void(^)(void))singleBlock {
    
    alertType_ = kAlertTypeBlock;
    
    cancelBlock = [singleBlock copy];
    
    [self hideCurrentAlert];
    self->alert = [[UIAlertView alloc] initWithTitle:title message:msg
                                            delegate:self
                                   cancelButtonTitle:singleButtonTitle
                                   otherButtonTitles:nil, nil];
    [self->alert show];
}


- (void)hideCurrentAlert {


    if (self->alert) {
        self->hideWithoutAction = YES;
        [self->alert dismissWithClickedButtonIndex:0 animated:NO];
        [self->alert release];
        self->alert = nil;
    }
    
    self->hideWithoutAction = NO;
}


- (void)showAlertWithTextFieldTitle:(NSString *)title
                        placeHolder:(NSString *)placeHolder
                             secure:(BOOL)secure
                        cancelTitle:(NSString *)cancelTitle
                       confirmTitle:(NSString *)confirmTitle
                       confirmBlock:(void(^)(NSString* text))confirm {
    
    alertType_ = kAlertTypeTextFieldBlock;
    self->textFieldBlock = [confirm copy]; 

    [self hideCurrentAlert];


    self->alert = [[UIAlertView alloc] initWithTitle:title message:@"\n"
                                            delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:confirmTitle, nil];

    UITextField* tf = [[[UITextField alloc] initWithFrame:CGRectMake(12.0f, 50.0f, 260.0f, 25.0f)] autorelease];
    tf.backgroundColor = [UIColor whiteColor];
    tf.placeholder = placeHolder;
    tf.secureTextEntry = secure;
    tf.tag = ALERT_MANAGER_TEXTFIELD_TAG;
    tfText_ = tf;
    
    [self->alert addSubview:tf];
    [self->alert show];
    
    [tf becomeFirstResponder];
}


- (void)setLocalAlarmWithMessage:(NSString *)msg
                   withAlarmTime:(NSDate *)time {
    
    UILocalNotification* alarm = [[UILocalNotification alloc] init];
    if (alarm) {
        alarm.fireDate          = time;
        alarm.timeZone          = [NSTimeZone defaultTimeZone];
        alarm.repeatInterval    = 0;
        alarm.alertBody         = msg;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:alarm];
        [alarm release];
    } else {
        [Log info:@"%s LocalNotification register failed.", __func__];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (0 == buttonIndex) {
        if (cancelBlock)
            cancelBlock();
        
    } else if (1 == buttonIndex) {
        
        if ( (alertType_ == kAlertTypeBlock) && confirmBlock) {
            
            confirmBlock();
            
        } else if ((alertType_ == kAlertTypeTextFieldBlock) && textFieldBlock) {
            
            if(nil == tfText_.text)
                tfText_.text = @"";
            textFieldBlock(tfText_.text);
        }
        
    } else {
        if (optionBlock)
            optionBlock();
    }
    
    if (cancelBlock) {
        [cancelBlock release];
        cancelBlock = nil;
    }
    
    if (confirmBlock) {
        [confirmBlock release];
        confirmBlock = nil;
    }
    
    if (optionBlock) {
        [optionBlock release];
        optionBlock = nil;
    }
}


@end
