//
//  AppDelegate.m
//  Kogatano_Demo_OSX
//
//  Created by Joe 楠 on 28/09/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import "AppDelegate.h"
#import "KOGHomeWindow.h"

@interface AppDelegate ()
@property (nonatomic, strong) NSMutableArray *windows;
@end

@implementation AppDelegate

- (IBAction)createNewWindow:(id)sender {
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;

    KOGHomeWindow *homeWindow = [[KOGHomeWindow alloc] initWithContentRect:CGRectMake(0, 0, 500, 400) styleMask:style backing:NSBackingStoreRetained defer:NO];
    [homeWindow center];
    [homeWindow makeKeyAndOrderFront:self];

    [self.windows addObject:homeWindow];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.windows = [NSMutableArray array];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
