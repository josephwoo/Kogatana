//
//  ONIUSBConnector.m
//  Kogatana
//
//  Created by Joe 楠 on 26/09/2017.
//  Copyright © 2017 Joe 楠. All rights reserved.
//

#import "KOGUSBConnector.h"

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

        //[self handleMessage:@"[Status]: 🔌 USB attached to Mac! \n[Status]: Please enable 📡 debug service inside iOS App, then click \'Connect\'" logType:KOGLogTypeStateLogNormal];
    }];

    [nc addObserverForName:PTUSBDeviceDidDetachNotification object:PTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *deviceID = [note.userInfo objectForKey:@"DeviceID"];
        NSLog(@"PTUSBDeviceDidDetachNotification: %@", deviceID);

        //[self handleMessage:@"[Status]: ⚠️ USB detached From Mac" logType:KOGLogTypeStateLogCaution];
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
            NSLog(@"🚫 Failed to connect to device: %@", error);
        }

        if (completionHandler) { completionHandler(self.isConnected, error); }
    }];
}

@end

