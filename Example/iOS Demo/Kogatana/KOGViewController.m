//
//  KOGViewController.m
//  Kogatana
//
//  Created by josephwoo on 09/28/2017.
//  Copyright (c) 2017 josephwoo. All rights reserved.
//

#import "KOGViewController.h"
#import <KOGListener.h>

@interface KOGViewController () <KOGListenningDelegate>
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (nonatomic, strong) KOGListener *listener;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@end

@implementation KOGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messageTextView.editable = NO;
    self.listener = [[KOGListener alloc] initWithDelegate:self];
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


#pragma mark - display message
- (void)appendOutputMessage:(NSString*)message
{
    NSString *text = self.messageTextView.text;
    if (text.length == 0) {
        self.messageTextView.text = [text stringByAppendingString:message];
    } else {
        self.messageTextView.text = [text stringByAppendingFormat:@"\n%@", message];
        [self.messageTextView scrollRangeToVisible:NSMakeRange(self.messageTextView.text.length, 0)];
    }
}

#pragma mark - KOGListenningDelegate
- (void)listener:(KOGListener *)listener didReceiveMessage:(NSString *)logMessage
{
    if (![logMessage isEqualToString:@"clear"]) {
        [self appendOutputMessage:logMessage];
        return;
    }

    self.messageTextView.text = @"Received:";
    [self.messageTextView scrollRangeToVisible:NSMakeRange(self.messageTextView.text.length, 0)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
