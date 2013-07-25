//
//  UIDevice+Target.m
//  ChorusVC
//
//  Created by cyh on 13. 2. 18..
//  Copyright (c) 2013년 saeha. All rights reserved.
//

#import "UIDevice+Target.h"

@implementation UIDevice (Target)

+ (BOOL)isIPad {

    BOOL ret = YES;
    UIUserInterfaceIdiom idom = [[self currentDevice] userInterfaceIdiom];
    if (idom == UIUserInterfaceIdiomPhone)
        ret = NO;

    return ret;
}

+ (CGRect)targetFrame {
    return [UIScreen mainScreen].applicationFrame;
}

+ (CGSize)targetResolution {
    return [UIScreen mainScreen].applicationFrame.size;
}

+ (CGFloat)targetWidth {
    return [UIScreen mainScreen].applicationFrame.size.width;
}

+ (CGFloat)targetHeight {
    return [UIScreen mainScreen].applicationFrame.size.height;
}

@end
