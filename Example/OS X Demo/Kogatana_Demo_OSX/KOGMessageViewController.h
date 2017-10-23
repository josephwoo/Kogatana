//
//  KOGMessageViewController.h
//  Kogatana
//
//  Created by Joe 楠 on 23/10/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KOGConnector;

@interface KOGMessageViewController : NSViewController
@property (nonatomic, strong) KOGConnector *connector;
@end
