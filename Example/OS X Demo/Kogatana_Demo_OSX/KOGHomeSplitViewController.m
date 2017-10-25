//
//  KOGHomeSplitViewController.m
//  Kogatana
//
//  Created by Joe 楠 on 23/10/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import "KOGHomeSplitViewController.h"
#import "KOGLogViewController.h"
#import "KOGMessageViewController.h"

@interface KOGHomeSplitViewController ()

@end

@implementation KOGHomeSplitViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupChildVCtrlrs];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    KOGLogViewController *logVCtrlr = [self.childViewControllers firstObject];
    KOGMessageViewController *messageVCtrlr = [self.childViewControllers lastObject];
    [messageVCtrlr setConnector:logVCtrlr.connector];
}

- (void)setupChildVCtrlrs
{
    NSStoryboard *mainboard = [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    KOGLogViewController *logVCtrlr = [mainboard instantiateControllerWithIdentifier:@"KOGLogVC"];
    KOGMessageViewController *messageVCtrlr = [mainboard instantiateControllerWithIdentifier:@"KOGMessageVC"];
    [self setChildViewControllers:@[logVCtrlr, messageVCtrlr]];
}

@end
