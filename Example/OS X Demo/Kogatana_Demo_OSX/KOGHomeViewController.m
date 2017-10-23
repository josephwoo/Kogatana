//
//  KOGHomeViewController.m
//  Kogatano_Demo_OSX
//
//  Created by Joe 楠 on 28/09/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import "KOGHomeViewController.h"
#import <QuartzCore/QuartzCore.h>

#import <KOGConnector.h>

static void *KOGObserverContextConnectStated = &KOGObserverContextConnectStated;

@interface KOGHomeViewController () <KOGConnectionDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;
@property (strong, nonatomic) NSDictionary *consoleTextAttributes;

@property (weak) IBOutlet NSButton *scanButton;
@property (weak) IBOutlet NSProgressIndicator *scanIdicator;

@property (weak) IBOutlet NSTextField *portTextField;
@property (nonatomic, strong) KOGConnector *connector;
@property (nonatomic, strong) NSNumber *connectPort;


@end

@implementation KOGHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.consoleTextAttributes = [self.class textAttributesMap];

    self.connector = [[KOGConnector alloc] initWithDelegate:self];
    [self.connector addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:KOGObserverContextConnectStated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == KOGObserverContextConnectStated) {
        NSNumber *stateNumber = change[NSKeyValueChangeNewKey];
        [self updateScanButtonUIWithConnetorState:stateNumber.boolValue];
    }
}

- (void)updateScanButtonUIWithConnetorState:(BOOL)isConnected
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scanIdicator stopAnimation:nil];
        NSString *connectButtonTitle = isConnected ? @"🛑 Stop" : @"Scan";
        [self.scanButton setTitle:connectButtonTitle];
        [self.scanButton setTag:isConnected];
        self.portTextField.enabled = !isConnected;
    });
}
#pragma mark init END -

- (IBAction)scanToConnect:(NSButton *)sender {
    BOOL needScan = !self.scanButton.tag;
    NSString *connectButtonTitle = needScan ? @"🛑 Stop" : @"Scan";
    [self.scanButton setTitle:connectButtonTitle];
    [self.scanButton setTag:needScan];
    self.portTextField.enabled = !needScan;

    if (needScan) {
        [self.scanIdicator startAnimation:nil];
        [self _connectToDevice];
    } else {
        [self.scanIdicator stopAnimation:nil];
        [self.connector disconnect];
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

    self.connectPort = @(port);
    [self.connector connectToPort:self.connectPort];
}

- (IBAction)sendMessage:(id)sender {
    [self.connector sendMessage:@"Hello ~~"];
}

#pragma mark - ONIUSBConnectorOutputDelegate
static const NSTimeInterval kReconnectDelay = 1.0;
- (void)connector:(KOGConnector *)connector didFinishConnectionWithError:(NSError *)error
{
    if (error && self.scanButton.tag) {
        [connector performSelector:@selector(connectToPort:) withObject:self.connectPort afterDelay:kReconnectDelay];
    } else {
        if (self.scanButton.tag) {
            self.connector = connector;
            [self clearConsoleOutput];
        }
    }
}

- (void)connector:(KOGConnector *)connector didEndWithError:(NSError *)error
{
    if (error) {
        [self presentMessage:@"[Status]: ⚠️ Closed Connection!" consoleTextAttributes:KOGLogTypeStateLogCaution];
    }
}

- (void)connector:(KOGConnector *)connector didReceiveMessageType:(KOGLogType)type message:(NSString *)logMessage
{
    [self presentMessage:logMessage consoleTextAttributes:type];
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
