//
//  KOGWiFiConnector.m
//  Expecta
//
//  Created by Joe 楠 on 13/10/2017.
//

#import "KOGWiFiConnector.h"

@implementation KOGWiFiConnector
- (instancetype)initWithPTChannelDelegate:(id<PTChannelDelegate>)aChannelDelegate
{
    self = [super init];
    if (self) {
        self.channelDelegate = aChannelDelegate;
    }
    return self;
}

- (void)connectToPort:(int)aPort completionHandler:(void (^)(BOOL, NSError *))completionHandler
{
    PTChannel *channel = [PTChannel channelWithDelegate:self.channelDelegate];
    [channel connectToPort:aPort IPv4Address:INADDR_LOOPBACK callback:^(NSError *error, PTAddress *address) {
        self.isConnected = (nil == error);
        if (self.isConnected) {
            self.connectedChannel = channel;
        } else {
//            NSLog(@"🚫 Failed to connect to device: %@", error);
            NSLog(@"🚫 Failed to connect by Wi-Fi");
        }

        if (completionHandler) { completionHandler(self.isConnected, error); }
    }];
}

@end

