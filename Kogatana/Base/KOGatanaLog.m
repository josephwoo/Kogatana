//
//  KOGatanaLog.m
//  Kogatana
//
//  Created by Joe 楠 on 27/09/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import "KOGatanaLog.h"
#import "PTProtocol.h"

@implementation KOGatanaLog

- (instancetype)initWithLogType:(KOGLogType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (dispatch_data_t)payload
{
    NSParameterAssert(self.logMessage.length);
    
    NSData *data = [self.logMessage dataUsingEncoding:NSUTF8StringEncoding];
    dispatch_data_t dispatchData = [data createReferencingDispatchData];
    return dispatchData;
}

@end
