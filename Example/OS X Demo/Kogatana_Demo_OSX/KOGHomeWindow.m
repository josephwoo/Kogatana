//
//  KOGHomeWindow.m
//  Kogatana
//
//  Created by Joe 楠 on 24/10/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import "KOGHomeWindow.h"
#import "KOGHomeSplitViewController.h"

@implementation KOGHomeWindow
- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
    if (self) {
        KOGHomeSplitViewController *aSplitVCtrlr = [[KOGHomeSplitViewController alloc] init];
        [self setContentViewController:aSplitVCtrlr];
    }
    return self;
}

@end
