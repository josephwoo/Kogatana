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
@property (weak) IBOutlet NSTextField *messageTextField;
@end

@implementation KOGMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)sendMessage:(id)sender {
    [self.connector sendMessage:self.messageTextField.stringValue];
}

@end
