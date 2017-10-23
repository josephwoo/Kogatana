//
//  KOGLogViewController.m
//  Kogatana
//
//  Created by Joe 楠 on 23/10/2017.
//  Copyright © 2017 josephwoo. All rights reserved.
//

#import "KOGLogViewController.h"
#import <QuartzCore/QuartzCore.h>

static void *KOGObserverContextConnectStated = &KOGObserverContextConnectStated;

@interface KOGLogViewController () <KOGConnectionDelegate, NSTextFieldDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;
@property (strong, nonatomic) NSDictionary *consoleTextAttributes;

@property (weak) IBOutlet NSButton *scanButton;
@property (weak) IBOutlet NSProgressIndicator *scanIdicator;

@property (weak) IBOutlet NSTextField *portTextField;
@property (nonatomic, strong, readwrite) KOGConnector *connector;
@property (nonatomic, assign) int connectPort;

@end

@implementation KOGLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.portTextField.delegate = self;
    self.consoleTextAttributes = [self.class textAttributesMap];

    self.connector = [[KOGConnector alloc] initWithDelegate:self];
    [self.connector addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:KOGObserverContextConnectStated];
    self.connectPort = self.portTextField.placeholderString.intValue;
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
    int port = self.connectPort;
    if (port <= 1024 || port > 65535) {
        [self presentMessage:@"[Status]: 🚫 Illegal Port Number: must 1024 < port < 65536" consoleTextAttributes:KOGLogTypeStateLogCaution];
        [self updateScanButtonUIWithConnetorState:NO];
        return;
    }

    [self.connector connectToPort:@(self.connectPort)];
}


#pragma mark - KOGConnectionDelegate
static const NSTimeInterval kReconnectDelay = 1.0;
- (void)connector:(KOGConnector *)connector didFinishConnectionWithError:(NSError *)error
{
    if (error && self.scanButton.tag) {
        [connector performSelector:@selector(connectToPort:) withObject:@(self.connectPort) afterDelay:kReconnectDelay];
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

#pragma mark - NSTextFieldDelegate
- (void)controlTextDidChange:(NSNotification *)noti
{
    NSTextField *portTF = noti.object;
    NSString *portString = portTF.stringValue;
    self.connectPort = portString.length ? portString.intValue : portString.intValue;
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
