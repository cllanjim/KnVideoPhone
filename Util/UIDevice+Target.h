//
//  UIDevice+Target.h
//  ChorusVC
//
//  Created by cyh on 13. 2. 18..
//  Copyright (c) 2013년 saeha. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMAGE_BY_TARTGET(nomar, retina4) (([[UIScreen mainScreen] bound].size.height <= 480.0) ? regular : retina4)

@interface UIDevice (Target)
+ (BOOL)isIPad;
+ (CGRect)targetFrame;
+ (CGSize)targetResolution;
+ (CGFloat)targetWidth;
+ (CGFloat)targetHeight;
@end
