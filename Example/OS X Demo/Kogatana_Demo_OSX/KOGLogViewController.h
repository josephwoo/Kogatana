//
//  KOGLogViewController.h
//  Kogatana
//
//  Created by Joe 楠 on 23/10/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <KOGConnector.h>

@interface KOGLogViewController : NSViewController
@property (nonatomic, strong, readonly) KOGConnector *connector;
@end
