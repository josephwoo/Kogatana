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

- (instancetype)initWithDelegate:(id<KOGConnectorOutputDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (self) {
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

        [self handleMessage:@"[Status]: 🔌 USB attached to Mac! \n[Status]: Please enable 📡 debug service inside iOS App, then click \'Connect\'" logType:KOGLogTypeStateLogNormal];
    }];

    [nc addObserverForName:PTUSBDeviceDidDetachNotification object:PTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *deviceID = [note.userInfo objectForKey:@"DeviceID"];
        NSLog(@"PTUSBDeviceDidDetachNotification: %@", deviceID);

        [self disconnect];
        [self handleMessage:@"[Status]: ⚠️ USB detached From Mac" logType:KOGLogTypeStateLogCaution];
    }];
}

- (void)connect
{
    dispatch_async(self.connectedQueue, ^{
        if (self.isConnectedToDevice) return;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self connectToDeviceByUSBHub];
        });
    });
}

- (void)connectToPort:(int)aPort
{
    [super connectToPort:aPort];
    [self connect];
}

- (void)connectToDeviceByUSBHub
{
    PTChannel *channel = [PTChannel channelWithDelegate:self];
    [channel connectToPort:self.connectPort overUSBHub:PTUSBHub.sharedHub deviceID:self.currentConnectedDeviceID callback:^(NSError *error) {
        if (nil == error) {
            self.connectedChannel = channel;
            self.isConnectedToDevice = YES;
        }

        __strong id<KOGConnectorOutputDelegate> strongDelegate = self.outputHandler;
        if (strongDelegate && [strongDelegate respondsToSelector:@selector(connector:didCompleteWithError:)]) {
            [strongDelegate connector:self didCompleteWithError:error];
        }
    }];
}

@end
