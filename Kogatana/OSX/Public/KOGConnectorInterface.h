//
//  KOGConnectorInterface.h
//  Pods-Kogatana
//
//  Created by Joe 楠 on 23/10/2017.
//

#ifndef KOGConnectorInterface_h
#define KOGConnectorInterface_h

#import <Foundation/Foundation.h>
#import "KOGatanaLog.h"

@class PTChannel;
@protocol PTChannelDelegate;

@interface KOGConnectorInterface : NSObject
@property (nonatomic, assign) BOOL isConnected;
@property (strong) PTChannel *connectedChannel;
@property (nonatomic, weak) id<PTChannelDelegate> channelDelegate;

- (instancetype)initWithPTChannelDelegate:(id<PTChannelDelegate>)aChannelDelegate;

- (void)connectToPort:(int)aPort completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;
- (void)disconnectCompletionHandler:(void (^)())completionHandler;

- (void)sendLog:(KOGatanaLog *)aLog;
@end

#endif /* KOGConnectorInterface_h */
