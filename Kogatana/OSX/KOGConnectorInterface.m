//
//  KOGConnectorInterface.m
//  Expecta
//
//  Created by Joe 楠 on 23/10/2017.
//

#import "KOGConnectorInterface.h"
#import "PTChannel.h"

@implementation KOGConnectorInterface

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)disconnectCompletionHandler:(void (^)())completionHandler
{
    [self.connectedChannel close];
    self.isConnected = NO;

    if (completionHandler) { completionHandler(); }
}

- (void)sendLog:(KOGatanaLog *)aLog
{
    [self.connectedChannel sendFrameOfType:aLog.type tag:PTFrameNoTag withPayload:aLog.payload callback:^(NSError *error) {
        if (error) {
            NSLog(@"🚫 Failed to send message: %@", error);
        }
    }];
}

@end
