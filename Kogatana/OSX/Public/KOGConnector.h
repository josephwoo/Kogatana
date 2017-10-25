//
//  KOGConnector.h
//  Expecta
//
//  Created by Joe 楠 on 13/10/2017.
//

#import <Foundation/Foundation.h>
#import "KOGatanaLog.h"

extern NSString *const KOGUSBDeviceDidAttachNotification;
extern NSString *const KOGUSBDeviceDidDetachNotification;

@protocol KOGConnectionDelegate;

@interface KOGConnector : NSObject
@property (nonatomic, assign, readonly) BOOL isConnected;

- (instancetype)initWithDelegate:(id<KOGConnectionDelegate>)delegate;

- (void)connectToPort:(NSNumber *)aPortNumber;
- (void)disconnect;

- (void)sendMessage:(NSString *)aMessage;
@end

@protocol KOGConnectionDelegate <NSObject>
- (void)connector:(KOGConnector *)connector didFinishConnectionWithError:(NSError *)error;
- (void)connector:(KOGConnector *)connector didReceiveMessageType:(KOGLogType)type message:(NSString *)logMessage;
- (void)connector:(KOGConnector *)connector didEndWithError:(NSError*)error;
@end
