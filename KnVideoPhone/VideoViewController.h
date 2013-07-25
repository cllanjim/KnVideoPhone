//
//  VideoViewController.h
//  KnVideoPhone
//
//  Created by cyh on 7/25/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kKNStreamModeServer,
    kKNStreamModeClient
}KNStreamMode;

@interface VideoViewController : UIViewController

@property (retain, nonatomic) IBOutlet UINavigationBar* naviBar;
@property (retain, nonatomic) IBOutlet UIView* viewPeer;
@property (retain, nonatomic) IBOutlet UIImageView* viewPeerImage;
@property (retain, nonatomic) IBOutlet UIView* viewPreview;
@property (retain, nonatomic) IBOutlet UILabel* lblMessage;

@property (assign, nonatomic) KNStreamMode streamMode;

- (IBAction)exit:(id)sender;

@end
