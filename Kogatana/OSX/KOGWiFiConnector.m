//
//  KOGWiFiConnector.m
//  Expecta
//
//  Created by Joe 楠 on 13/10/2017.
//

#import "KOGWiFiConnector.h"

@implementation KOGWiFiConnector

- (instancetype)initWithDelegate:(id<KOGConnectorOutputDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (self) {

    }
    return self;
}

- (void)connect
{
    dispatch_async(self.connectedQueue, ^{
        if (self.isConnectedToDevice) return;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self connectToDeviceOverWiFi];
        });
    });
}

- (void)connectToPort:(int)aPort
{
    [super connectToPort:aPort];
    [self connect];
}

- (void)connectToDeviceOverWiFi
{
    PTChannel *channel = [PTChannel channelWithDelegate:self];
    [channel connectToPort:self.connectPort IPv4Address:INADDR_LOOPBACK callback:^(NSError *error, PTAddress *address) {
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
