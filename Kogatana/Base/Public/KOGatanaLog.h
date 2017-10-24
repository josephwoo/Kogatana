//
//  KOGInfoLog.h
//  Kogatana
//
//  Created by Joe 楠 on 27/09/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KOGLogType) {
    KOGLogTypePing          = 927,  // for: Created by Joe 楠 on 27/09/2017.
    KOGLogTypePong          = 928,

    KOGLogTypeStateLogNormal    = 929,
    KOGLogTypeStateLogCaution   = 930,
    KOGLogTypeMessageNormal     = 931,
    KOGLogTypeMessageCaution    = 932,
    
    KOGLogTypeInValidFlag     = 933,    // MaxValue for if condition
};

@interface KOGatanaLog : NSObject
@property (assign, nonatomic, readonly) KOGLogType type;
@property (copy, nonatomic) NSString *logMessage;

- (instancetype)initWithLogType:(KOGLogType)type;

- (dispatch_data_t)payload;
@end
