//
//  KOGHomeViewController.m
//  Kogatano_Demo_OSX
//
//  Created by Joe 楠 on 28/09/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import "KOGHomeViewController.h"
#import <QuartzCore/QuartzCore.h>

#import <KOGUSBConnector.h>
#import <KOGWiFiConnector.h>

static void *KOGObserverContextConnectStated = &KOGObserverContextConnectStated;

@interface KOGHomeViewController () <KOGConnectorOutputDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;
@property (weak) IBOutlet NSButton *triggerButton;

@property (weak) IBOutlet NSButton *scanCheck;
@property (weak) IBOutlet NSProgressIndicator *scanIdicator;
@property (weak) IBOutlet NSTextField *portTextField;

@property (strong, nonatomic) NSDictionary *consoleTextAttributes;
@property (nonatomic, strong) KOGUSBConnector *usbConnector;
@property (strong, nonatomic) KOGWiFiConnector *wifiConnector;
@property (assign, nonatomic) BOOL isConnected;

@end

@implementation KOGHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.consoleTextAttributes = [self.class textAttributesMap];
    [self addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:KOGObserverContextConnectStated];

    self.usbConnector = [[KOGUSBConnector alloc] initWithDelegate:self];
    self.wifiConnector = [[KOGWiFiConnector alloc] initWithDelegate:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == KOGObserverContextConnectStated) {
        NSNumber *stateNumber = change[NSKeyValueChangeNewKey];
        BOOL isConnected = stateNumber.boolValue;
        NSString *connectButtonTitle = isConnected ? @"🛑 Disconnect" : @"Connect";
        [self.triggerButton setTitle:connectButtonTitle];
        self.scanCheck.enabled = !isConnected;
        self.portTextField.enabled = !isConnected;

        [self.scanCheck setState:NSControlStateValueOff];
        [self.scanIdicator stopAnimation:nil];
    }
}

#pragma mark init END -

- (IBAction)connectToDevice:(NSButton *)sender
{
    if (self.isConnected) {
        [self _disconnectToDevice];
    } else {
        [self _connectToDevice];
    }
}

- (IBAction)scanToConnect:(NSButton *)sender {
    if (sender.state == NSControlStateValueOn) {
        [self.scanIdicator startAnimation:nil];
        [self _connectToDevice];
    } else {
        [self.scanIdicator stopAnimation:nil];
    }
}

- (void)_connectToDevice
{
    NSString *portString = self.portTextField.stringValue;
    if (!portString.length) {
        portString = self.portTextField.placeholderString;
    }

    int port = portString.intValue;
    if (port <= 1024 || port > 65535) {
        [self presentMessage:@"[Status]: 🚫 Illegal Port Number!" consoleTextAttributes:KOGLogTypeStateLogCaution];
        return;
    }

    [self.usbConnector connectToPort:port];
    [self.wifiConnector connectToPort:port];
}

- (void)_disconnectToDevice
{
    [self.usbConnector disconnect];
    [self.wifiConnector disconnect];
}

#pragma mark - ONIUSBConnectorOutputDelegate
static const NSTimeInterval kReconnectDelay = 1.0;
- (void)connector:(KOGConnector *)connector didCompleteWithError:(NSError *)error
{
    if (error) {
        if (error.code == ENETDOWN) {
            [self presentMessage:@"[Status]: ⚠️ Closed Connection!" consoleTextAttributes:KOGLogTypeStateLogCaution];
            self.isConnected = NO;
        }

        if (self.scanCheck.state == NSControlStateValueOn) {
            [connector performSelector:@selector(connect) withObject:nil afterDelay:kReconnectDelay];
        }

        NSLog(@"🚫 Failed to connect to device: %@", error);
        return;
    }

    [self clearConsoleOutput];
    self.isConnected = YES;
}

- (void)connector:(KOGConnector *)connector didReceiveMessageType:(KOGLogType)type message:(NSString *)logMessage
{
    if ([[NSThread currentThread] isMainThread]) {
        [self presentMessage:logMessage consoleTextAttributes:type];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentMessage:logMessage consoleTextAttributes:type];
        });
    }
}

#pragma mark - Message Pressent
- (void)clearConsoleOutput
{
    [self.outputTextView.textStorage beginEditing];
    NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:@""];
    [self.outputTextView.textStorage setAttributedString:attributedMessage];
    [self.outputTextView.textStorage endEditing];
}

- (void)presentMessage:(NSString*)message consoleTextAttributes:(KOGLogType)attributesType
{
    [self.outputTextView.textStorage beginEditing];
    if (self.outputTextView.textStorage.length > 0) {
        message = [@"\n" stringByAppendingString:message];
    }

    NSDictionary *textAttributes = self.consoleTextAttributes[@(attributesType)];
    NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:message attributes:textAttributes];
    [self.outputTextView.textStorage appendAttributedString:attributedMessage];
    [self.outputTextView.textStorage endEditing];

    // 刷新显示最新
    [NSAnimationContext beginGrouping];
    [NSAnimationContext currentContext].duration = 0.15;
    [NSAnimationContext currentContext].timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    NSClipView* clipView = [[self.outputTextView enclosingScrollView] contentView];
    NSPoint newOrigin = clipView.bounds.origin;
    newOrigin.y += 5.0; // hack A 1/2
    [clipView setBoundsOrigin:newOrigin]; // hack A 2/2
    newOrigin.y += 1000.0;
    newOrigin = [clipView constrainScrollPoint:newOrigin];
    [clipView.animator setBoundsOrigin:newOrigin];
    [NSAnimationContext endGrouping];
}


#pragma mark - init Attributes
+ (NSDictionary *)textAttributesMap
{
    static NSDictionary *attributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *stateNormalAttributes = @{NSFontAttributeName : [NSFont fontWithName:@"Helvetica" size:16.0],
                                                NSForegroundColorAttributeName : [NSColor colorWithRed:29/255.0 green:193/255.0 blue:33/255.0 alpha:1.0]
                                                };
        NSDictionary *stateCautionAttributes = @{NSFontAttributeName : [NSFont fontWithName:@"Helvetica" size:16.0],
                                                 NSForegroundColorAttributeName : [NSColor redColor]
                                                 };
        NSDictionary *logNormalAttributes = @{NSFontAttributeName : [NSFont fontWithName:@"Monaco" size:13.0],
                                              NSForegroundColorAttributeName : [NSColor lightGrayColor]
                                              };
        NSDictionary *logCautionAttributes = @{NSFontAttributeName : [NSFont fontWithName:@"Monaco" size:13.0],
                                               NSForegroundColorAttributeName : [NSColor redColor]
                                               };
        attributes = @{
                       @(KOGLogTypeStateLogNormal)   : stateNormalAttributes,
                       @(KOGLogTypeStateLogCaution)  : stateCautionAttributes,
                       @(KOGLogTypeMessageNormal)   : logNormalAttributes,
                       @(KOGLogTypeMessageCaution)  : logCautionAttributes,
                       };
    });

    return attributes;
}

@end
