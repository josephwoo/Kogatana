//
//  ONIUSBConnector.m
//  Kogatana
//
//  Created by Joe 楠 on 26/09/2017.
//  Copyright © 2017 Joe 楠. All rights reserved.
//

#import "KOGUSBConnector.h"
#import "PTChannel.h"

@interface KOGUSBConnector ()
@property (nonatomic, strong) NSNumber *currentConnectedDeviceID;

@end

@implementation KOGUSBConnector
- (instancetype)initWithPTChannelDelegate:(id<PTChannelDelegate>)aChannelDelegate
{
    self = [super init];
    if (self) {
        self.channelDelegate = aChannelDelegate;
        [self startListeningForDevices];
    }
    return self;
}

- (void)startListeningForDevices
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserverForName:PTUSBDeviceDidAttachNotification object:PTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *deviceID = [note.userInfo objectForKey:@"DeviceID"];
        NSLog(@"PTUSBDeviceDidAttachNotification: %@", deviceID);
        self.currentConnectedDeviceID = deviceID;
    }];

    [nc addObserverForName:PTUSBDeviceDidDetachNotification object:PTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *deviceID = [note.userInfo objectForKey:@"DeviceID"];
        NSLog(@"PTUSBDeviceDidDetachNotification: %@", deviceID);
    }];
}

- (void)connectToPort:(int)aPort completionHandler:(void (^)(BOOL, NSError *))completionHandler
{
    PTChannel *channel = [PTChannel channelWithDelegate:self.channelDelegate];
    [channel connectToPort:aPort overUSBHub:PTUSBHub.sharedHub deviceID:self.currentConnectedDeviceID callback:^(NSError *error) {
        self.isConnected = (nil == error);
        if (self.isConnected) {
            self.connectedChannel = channel;
        } else {
//            NSLog(@"🚫 Failed to connect to device: %@", error);
            NSLog(@"🚫 Failed to connect by USB");
        }

        if (completionHandler) { completionHandler(self.isConnected, error); }
    }];
}

@end

