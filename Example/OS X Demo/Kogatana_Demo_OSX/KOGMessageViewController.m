//
//  KOGMessageViewController.m
//  Kogatana
//
//  Created by Joe 楠 on 23/10/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import "KOGMessageViewController.h"
#import <KOGConnector.h>

@interface KOGMessageViewController ()

@property (unsafe_unretained) IBOutlet NSTextView *messageTextView;
@end

@implementation KOGMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)sendMessage:(id)sender {
    NSString *message = self.messageTextView.textStorage.string;
    if (message.length) {
        [self.connector sendMessage:message];
    }
}

@end
