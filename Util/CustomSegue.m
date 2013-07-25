//
//  CustomSegue.m
//  MultiviewCPS
//
//  Created by cyh on 7/16/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#import "CustomSegue.h"

@implementation CustomSegue

- (void)perform {
    
    UIViewController* src = (UIViewController *)self.sourceViewController;
    UIViewController* dst = (UIViewController *)self.destinationViewController;
    
    dst.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [src presentViewController:dst animated:YES completion:nil];
}

@end
