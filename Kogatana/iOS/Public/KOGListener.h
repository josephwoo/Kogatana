//
//  KOGListener.h
//  Kogatana
//
//  Created by Joe 楠 on 26/09/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KOGListenningDelegate;

@interface KOGListener : NSObject
- (instancetype)initWithDelegate:(id<KOGListenningDelegate>)aDelegate;

- (void)startListenning;
- (void)listenToPort:(int)aPort;
- (void)sendLog:(NSString *)logMessage isStatus:(BOOL)isStatus;

@end

@protocol KOGListenningDelegate <NSObject>
- (void)listener:(KOGListener *)listener didAcceptConnectionFromAddress:(NSString *)address;
- (void)listener:(KOGListener *)listener didReceiveMessage:(NSString *)logMessage;
@end
