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

- (void)viewDidLoad {
    [super viewDidLoad];

    KOGLogViewController *logVCtrlr = [self.childViewControllers firstObject];
    KOGMessageViewController *messageVCtrlr = [self.childViewControllers lastObject];
    [messageVCtrlr setConnector:logVCtrlr.connector];
}

@end
