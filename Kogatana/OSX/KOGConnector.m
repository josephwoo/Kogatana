//
//  KOGConnector.m
//  Expecta
//
//  Created by Joe 楠 on 13/10/2017.
//

#import "KOGConnector.h"
#import "Kogatana-prefix.h"

@implementation KOGConnector
- (instancetype)initWithDelegate:(id<KOGConnectorOutputDelegate>)delegate
{
    self = [super init];
    if (self) {
        _connectedQueue = dispatch_queue_create("com.joe.onimaruConnectedQueue", DISPATCH_QUEUE_SERIAL);
        _connectPort = KOGLogPort;
        _outputHandler = delegate;
    }
    return self;
}

- (void)disconnect
{
    if (self.isConnectedToDevice) {
        [self.connectedChannel close];
        self.isConnectedToDevice = NO;

        __strong id<KOGConnectorOutputDelegate> strongDelegate = self.outputHandler;
        if (strongDelegate && [strongDelegate respondsToSelector:@selector(connector:didCompleteWithError:)]) {
            NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENETDOWN userInfo:nil];
            [strongDelegate connector:self didCompleteWithError:error];
        }
    }
}

- (void)connect
{
    // implemented by subClass
}

- (void)connectToPort:(int)aPort
{
    self.connectPort = aPort;
}

- (void)handleMessage:(NSString *)message logType:(KOGLogType)type
{
    __strong id<KOGConnectorOutputDelegate> strongDelegate = self.outputHandler;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(connector:didReceiveMessageType:message:)]) {
        [strongDelegate connector:self didReceiveMessageType:type message:message];
    }
}

- (void)sendMessage:(NSString *)aMessage
{
    KOGatanaLog *log = [[KOGatanaLog alloc] initWithLogType:KOGLogTypeMessageNormal];
    log.logMessage = aMessage;
    [self.connectedChannel sendFrameOfType:log.type tag:PTFrameNoTag withPayload:log.payload callback:^(NSError *error) {
        if (error) {
            NSLog(@"🚫 Failed to send message: %@", error);
        }
    }];
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
    [self disconnect];

    if (error) {
        __strong id<KOGConnectorOutputDelegate> strongDelegate = self.outputHandler;
        if (strongDelegate && [strongDelegate respondsToSelector:@selector(connector:didCompleteWithError:)]) {
            [strongDelegate connector:self didCompleteWithError:error];
        }
    }
}

@end
