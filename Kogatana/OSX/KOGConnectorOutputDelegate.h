//
//  KOGConnectorOutputDelegate.h
//  Pods
//
//  Created by Joe 楠 on 13/10/2017.
//

@class KOGConnector;

@protocol KOGConnectorOutputDelegate <NSObject>
- (void)connector:(KOGConnector *)connector didCompleteWithError:(NSError *)error;
- (void)connector:(KOGConnector *)connector didReceiveMessageType:(KOGLogType)type message:(NSString *)logMessage;

@end
