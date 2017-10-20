//
//  KOGListener.h
//  Kogatana
//
//  Created by Joe 楠 on 26/09/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KOGListener : NSObject

- (void)startListenning;
- (void)listenToPort:(int)aPort;
- (void)sendLog:(NSString *)logMessage isStatus:(BOOL)isStatus;
@end
