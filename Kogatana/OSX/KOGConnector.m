//
//  KOGConnector.m
//  Expecta
//
//  Created by Joe 楠 on 13/10/2017.
//

#import "KOGConnector.h"
#import "PTChannel.h"

#import "KOGUSBConnector.h"
#import "KOGWiFiConnector.h"

@interface KOGConnector () <PTChannelDelegate>
@property (nonatomic, strong) dispatch_group_t connectGroup;
@property (nonatomic, weak) id<KOGConnectionDelegate> connectionDelegate;
@property (nonatomic, weak) KOGConnectorInterface *connectedConnector;
@property (nonatomic, strong) NSArray<KOGConnectorInterface *> *connectors;
@property (nonatomic, assign, readwrite) BOOL isConnected;
@end

@implementation KOGConnector

- (instancetype)initWithDelegate:(id<KOGConnectionDelegate>)delegate
{
    self = [super init];
    if (self) {
        _connectGroup = dispatch_group_create();
        _connectionDelegate = delegate;
    }

    KOGUSBConnector *anUsbConnector = [[KOGUSBConnector alloc] initWithPTChannelDelegate:self];
    KOGWiFiConnector *aWiFiConnector = [[KOGWiFiConnector alloc] initWithPTChannelDelegate:self];
    _connectors = @[anUsbConnector, aWiFiConnector];

    return self;
}

- (void)connectToPort:(NSNumber *)aPortNumber
{
    if (self.isConnected) return;

    int port = aPortNumber.intValue;
    if (port <= 1024 || port > 65535) {
        NSLog(@"🚫 Illegal Port Number!");
        return;
    }

    __block NSError *connectError = nil;
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(0, 0);
    for (KOGConnectorInterface *aConnector in self.connectors) {
        dispatch_group_async(self.connectGroup, backgroundQueue, ^{
            [aConnector connectToPort:port completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    self.isConnected = YES;
                    self.connectedConnector = aConnector;
                } else {
                    connectError = error;
                }
            }];
        });
    }

    dispatch_group_notify(self.connectGroup, dispatch_get_main_queue(), ^{
        [self finishConnectionWithError: self.isConnected ? nil : connectError];
    });
}

- (void)disconnect
{
    if (NO == self.isConnected) {
        return;
    }

    [self.connectedConnector disconnectCompletionHandler:^{
        self.isConnected = NO;
    }];

}

- (void)sendMessage:(NSString *)aMessage
{
    KOGatanaLog *log = [[KOGatanaLog alloc] initWithLogType:KOGLogTypeMessageNormal];
    log.logMessage = aMessage;
    [self.connectedConnector sendLog:log];
}

#pragma mark - Private Functions
- (void)handleMessage:(NSString *)message logType:(KOGLogType)type
{
    __strong id<KOGConnectionDelegate> strongDelegate = self.connectionDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(connector:didReceiveMessageType:message:)]) {
        if ([[NSThread currentThread] isMainThread]) {
            [strongDelegate connector:self didReceiveMessageType:type message:message];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongDelegate connector:self didReceiveMessageType:type message:message];
            });
        }
    }
}

- (void)finishConnectionWithError:(NSError *)anError
{
    __strong id<KOGConnectionDelegate> strongDelegate = self.connectionDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(connector:didFinishConnectionWithError:)]) {
        if ([[NSThread currentThread] isMainThread]) {
            [strongDelegate connector:self didFinishConnectionWithError:anError];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongDelegate connector:self didFinishConnectionWithError:anError];
            });
        }
    }
}

#pragma mark - PTChannelDelegate

- (BOOL)ioFrameChannel:(PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
    if (type >= KOGLogTypeInValidFlag) {
        NSString *errorMessage = [NSString stringWithFormat:@"🚫 Received unexpected log of LogType = %u", type];
        [self handleMessage:[@"[Status]: " stringByAppendingString:errorMessage] logType:KOGLogTypeStateLogCaution];
        return NO;
    }

    return YES;
}


- (void)ioFrameChannel:(PTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(PTData*)payload
{
    NSString *logMessage = nil;

    switch (type) {
        case KOGLogTypeStateLogNormal:
        {
            NSData *data = [NSData dataWithContentsOfDispatchData:payload.dispatchData];
            NSString *deviceStatus = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            logMessage = [@"[Status]: " stringByAppendingString:deviceStatus];
        } break;

        case KOGLogTypePong:
            //[self pongWithTag:tag error:nil];
            break;

        default:
        {
            NSData *data = [NSData dataWithContentsOfDispatchData:payload.dispatchData];
            logMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } break;
    }

    [self handleMessage:logMessage logType:type];
}

- (void)ioFrameChannel:(PTChannel*)channel didEndWithError:(NSError*)error {
    if (!error) {
        return;
    }

    self.isConnected = NO;
    __strong id<KOGConnectionDelegate> strongDelegate = self.connectionDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(connector:didEndWithError:)]) {
        if ([[NSThread currentThread] isMainThread]) {
            [strongDelegate connector:self didEndWithError:error];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongDelegate connector:self didEndWithError:error];
            });
        }
    }
}

@end

