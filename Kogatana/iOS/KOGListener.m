//
//  KOGListener.m
//  Kogatana
//
//  Created by Joe 楠 on 26/09/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import "KOGListener.h"
#import "Kogatana-prefix.h"

#import "PTChannel.h"
#import "KOGatanaLog.h"

@interface KOGListener () <PTChannelDelegate>
@property (strong) PTChannel *serverChannel;
@property (strong) PTChannel *peerChannel;
@property (nonatomic, assign) int listenPort;
@property (nonatomic, weak) id<KOGListenningDelegate> delegate;
@property (nonatomic, strong) NSMutableArray<KOGatanaLog *> *unSentLogStorage;

@end

@implementation KOGListener

- (instancetype)initWithDelegate:(id<KOGListenningDelegate>)aDelegate
{
    self = [super init];
    if (self) {
        _unSentLogStorage = [NSMutableArray array];
        _listenPort = KOGLogPort;
        _delegate = aDelegate;
    }
    return self;
}

- (void)startListenning
{
    [self listenToPort:self.listenPort];
}

- (void)listenToPort:(int)aPort
{
    self.listenPort = aPort;
    PTChannel *channel = [PTChannel channelWithDelegate:self];
    [channel listenOnPort:self.listenPort IPv4Address:INADDR_LOOPBACK callback:^(NSError *error) {
        if (error) {
            NSLog(@"🚫 Failed to listen on 127.0.0.1:%d: %@", self.listenPort, error);
            return;
        }

        NSLog(@"📡 Listening on 127.0.0.1:%d", self.listenPort);
        self.serverChannel = channel;
    }];
}

- (void)sendLog:(NSString *)message isStatus:(BOOL)isStatus
{
    KOGLogType logType = isStatus ? KOGLogTypeMessageNormal : KOGLogTypeMessageCaution;
    [self _sendMessage:message logType:logType];
}

- (void)sendDeviceMessage:(NSString *)deviceStatus
{
    [self _sendMessage:deviceStatus logType:KOGLogTypeStateLogNormal];
}

static NSString *kUnSentMessageLockToken = @"kUnSentMessageLockToken";
- (void)_sendMessage:(NSString *)message logType:(KOGLogType)type
{
    if (!message.length) {
        NSLog(@"🚫 LogMessage must not be nil!");
        return;
    }

    KOGatanaLog *log = [[KOGatanaLog alloc] initWithLogType:type];
    log.logMessage = message;

    if (nil == self.peerChannel) {
        @synchronized (kUnSentMessageLockToken) {
            [self.unSentLogStorage addObject:log];
        }
        NSLog(@"🚫 Can not send message — Device Not Connected!");
        return;
    }

    [self _sendKogatanaLog:log];
}

- (void)_sendKogatanaLog:(KOGatanaLog *)log
{
    [self.peerChannel sendFrameOfType:log.type tag:PTFrameNoTag withPayload:log.payload callback:^(NSError *error) {
        if (error) {
            NSLog(@"🚫 Failed to send message: %@", error);
        }
    }];
}

#pragma mark - PTChannelDelegate

- (BOOL)ioFrameChannel:(PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
    if (channel != self.peerChannel) {
        // A previous channel that has been canceled but not yet ended. Ignore.
        return NO;
    } else if (type > KOGLogTypeInValidFlag) {
        NSLog(@"🚫 Received unexpected log of LogType = %u", type);
        [channel close];
        return NO;
    } else {
        return YES;
    }
}

- (void)ioFrameChannel:(PTChannel*)channel didAcceptConnection:(PTChannel*)otherChannel fromAddress:(PTAddress*)address {
    if (nil == otherChannel) {
        return;
    }

    // Cancel any other connection. We are FIFO, so the last connection
    // established will cancel any previous connection and "take its place".
    if (self.peerChannel) {
        [self.peerChannel cancel];
    }

    // Weak pointer to current connection. Connection objects live by themselves
    // (owned by its parent dispatch queue) until they are closed.
    self.peerChannel = otherChannel;
    self.peerChannel.userInfo = address;
    
    NSLog(@"🔗 Connected to %@", address);
    __strong id<KOGListenningDelegate> strongDelegate = self.delegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(listener:didAcceptConnectionFromAddress:)]) {
        @within_main_thread(^void() {
            [self.delegate listener:self didAcceptConnectionFromAddress:address.description];
        });
    }

    // 补偿发送未连接时，未发送的 log
    if (self.unSentLogStorage.count) {
        @synchronized (kUnSentMessageLockToken) {
            for (KOGatanaLog *unSentlog in self.unSentLogStorage) {
                [self _sendKogatanaLog:unSentlog];
            }
            [self.unSentLogStorage removeAllObjects];
        }
    }
}

- (void)ioFrameChannel:(PTChannel *)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(PTData *)payload
{
    __strong id<KOGListenningDelegate> strongDelegate = self.delegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(listener:didReceiveMessage:)]) {
        NSData *data = [NSData dataWithContentsOfDispatchData:payload.dispatchData];
        NSString *logMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        @within_main_thread(^void() {
            [strongDelegate listener:self didReceiveMessage:logMessage];
        });
    }
}

- (void)ioFrameChannel:(PTChannel*)channel didEndWithError:(NSError*)error {
    if (error) {
        NSLog(@"🚫 %@ ended with error: %@", channel, error);
        return;
    }

    NSLog(@"⚠️ Disconnected from %@", channel.userInfo);
}
@end
