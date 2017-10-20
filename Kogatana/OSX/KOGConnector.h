//
//  KOGConnector.h
//  Expecta
//
//  Created by Joe 楠 on 13/10/2017.
//

#import <Foundation/Foundation.h>
#import "PTChannel.h"

#import "KOGatanaLog.h"
#import "KOGConnectorOutputDelegate.h"


@interface KOGConnector : NSObject <PTChannelDelegate>

@property (strong, nonatomic, readonly) dispatch_queue_t connectedQueue;
@property (strong) PTChannel *connectedChannel;
@property (nonatomic, assign) int connectPort;
@property (nonatomic, assign) BOOL isConnectedToDevice;
@property (weak, nonatomic, readonly) id<KOGConnectorOutputDelegate> outputHandler;

- (instancetype)initWithDelegate:(id<KOGConnectorOutputDelegate>)delegate;

- (void)connect;
- (void)connectToPort:(int)aPort;
- (void)disconnect;

- (void)handleMessage:(NSString *)message logType:(KOGLogType)type;
- (void)sendMessage:(NSString *)aMessage;
@end
