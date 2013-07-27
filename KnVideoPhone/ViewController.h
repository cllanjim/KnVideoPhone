//
//  ViewController.h
//  KnVideoPhone
//
//  Created by cyh on 7/24/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UILabel* lblIPAddress;
@property (retain, nonatomic) IBOutlet UITextField* tfIPAddress;
@property (retain, nonatomic) IBOutlet UITextField* tfPort;
@property (retain, nonatomic) IBOutlet UIButton* btnStartServer;
@property (retain, nonatomic) IBOutlet UIButton* btnConnectServer;
@property (retain, nonatomic) IBOutlet UITextField* tfCaptureFPS;
@property (retain, nonatomic) IBOutlet UISegmentedControl* segResolution;

- (IBAction)startServer:(id)sender;
- (IBAction)connectToServer:(id)sender;

@end
