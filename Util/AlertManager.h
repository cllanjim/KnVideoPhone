//
//  AlertManager.h
//  iMultiviewUC
//
//  Created by YH CHOI on 12. 2. 9..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
/**
    @class      : AlertManager
    @date       : 2012/02/16
    @author     : 최영현 (cyh3813@saeha.com)
    @brief      : 얼럿이 떠있는 상태에서 뷰 컨트롤러가 전환되어야 할 경우가 있어서 작성.
    @warning    :
 */

#import <Foundation/Foundation.h>

typedef enum _tagAlertType {
    
    kAlertTypeBlock = 0,
    kAlertTypeTextFieldBlock
    
}ALERT_TYPE;

#define ALERT_MANAGER_TEXTFIELD_TAG     200
@interface AlertManager : NSObject <UIAlertViewDelegate> {
}

+ (AlertManager *)sharedObject;
- (void)hideCurrentAlert;

////버튼처리시 파라메터 필요없는 경우 호출.
- (void)showAlertWithTitle:(NSString*)title 
                   message:(NSString *)msg 
               cancelTitle:(NSString *)cancelTitle
              confirmTitle:(NSString *)confirmTitle
               cancelBlack:(void(^)(void))cancel 
              confirmBlock:(void(^)(void))confirm;


- (void)showAlertWithTitle:(NSString*)title
                   message:(NSString *)msg
               cancelTitle:(NSString *)cancelTitle
              confirmTitle:(NSString *)confirmTitle
               optionTitle:(NSString *)opionTitle
               cancelBlack:(void(^)(void))cancel
              confirmBlock:(void(^)(void))confirm
               optionBlock:(void(^)(void))option;


- (void)showAlertWithTitle:(NSString*)title 
                   message:(NSString *)msg 
              singleButton:(NSString *)singleButtonTitle
         singleButtonBlock:(void(^)(void))singleBlock;


- (void)showAlertWithTextFieldTitle:(NSString *)title
                        placeHolder:(NSString *)placeHolder
                             secure:(BOOL)secure
                        cancelTitle:(NSString *)cancelTitle
                       confirmTitle:(NSString *)confirmTitle
                       confirmBlock:(void(^)(NSString* text))confirm;

- (void)setLocalAlarmWithMessage:(NSString *)msg withAlarmTime:(NSDate *)time;

@end
