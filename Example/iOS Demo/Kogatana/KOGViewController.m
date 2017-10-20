//
//  KOGViewController.m
//  Kogatana
//
//  Created by josephwoo on 09/28/2017.
//  Copyright (c) 2017 josephwoo. All rights reserved.
//

#import "KOGViewController.h"
#import <KOGListener.h>

@interface KOGViewController ()
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (nonatomic, strong) KOGListener *listener;
@end

@implementation KOGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.listener = [[KOGListener alloc] init];
}

- (IBAction)enableDebugLog:(id)sender
{
    NSString *portString = self.portTextField.text;
    if (!portString.length) {
        portString = self.portTextField.placeholder;
    }

    int port = portString.intValue;
    if (port <= 1024 || port > 65535) {
        NSLog(@"🚫 Illegal Port Number!");
        return;
    }
    [self.listener listenToPort:port];
}

- (IBAction)sendLog:(id)sender
{
    NSString *logMessage = [NSString stringWithFormat:@"%@ : ✅ Hello World!", [NSDate date]];
    [self.listener sendLog:logMessage isStatus:YES];
}

- (IBAction)sendErrorLog:(id)sender
{
    NSString *errorMessage = [NSString stringWithFormat:@"%@ : 🚫 Error!", [NSDate date]];
    [self.listener sendLog:errorMessage isStatus:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
