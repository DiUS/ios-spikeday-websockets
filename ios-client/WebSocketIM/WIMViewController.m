//
//  WIMViewController.m
//  WebSocketIM
//
//  Created by Ben Kersten on 9/05/13.
//  Copyright (c) 2013 Dius. All rights reserved.
//

#import "WIMViewController.h"

#import "SocketIOPacket.h"

@interface WIMViewController ()
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, strong) UITextView *inputView;
@property (nonatomic, strong) SocketIO *webSocket;
@property (nonatomic, strong) NSMutableArray *datasource;
@end

#define FONT_SIZE 14.0
#define CELL_CONTENT_MARGIN 10

@implementation WIMViewController

-(id)init {
  self = [super init];
  if (self) {
    self.datasource = [NSMutableArray array];
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(connect)
                                               name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(disconnect)
                                               name:UIApplicationDidEnterBackgroundNotification
                                             object:nil];
  
  return self;
}

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:CGRectZero];
  
  self.messageTableView = [[UITableView alloc] init];
  [self.messageTableView setDelegate:self];
  self.messageTableView.translatesAutoresizingMaskIntoConstraints = NO;
  self.messageTableView.dataSource = self;
  
  self.inputView = [[UITextView alloc] init];
  [self.inputView setDelegate:self];
  [self.inputView setReturnKeyType:UIReturnKeySend];
  self.inputView.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self.view addSubview:self.messageTableView];
  [self.view addSubview:self.inputView];
  
  NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_messageTableView, _inputView);
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_messageTableView]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:viewsDict]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_inputView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDict]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_messageTableView]-[_inputView(50)]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDict]];
}

-(void)connect {
  if (!self.webSocket) {
    self.webSocket = [[SocketIO alloc] initWithDelegate:self];
  }
  
  if (self.webSocket.isConnected || self.webSocket.isConnecting) {
    return;
  }
  
  NSString *location = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ServerLocation"];
  DLog(@"location: %@", location);
  NSURL *url = [NSURL URLWithString:location];
  [self.webSocket connectToHost:url.host onPort:[url.port integerValue]];
}

-(void)disconnect {
  if (!self.webSocket) {
    return;
  }
  
  if (!self.webSocket.isConnected || !self.webSocket.isConnecting) {
    return;
  }

  [self.webSocket disconnect];
}

-(void)send:(NSString*)message {
  if (!self.webSocket) {
    return;
  }
  
  if (!self.webSocket.isConnected) {
    return;
  }
  
  DLog(@"Send message: %@", message);
  [self.webSocket sendMessage:message];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  
  if([text isEqualToString:@"\n"]) {
    NSString *message = textView.text;
    
    [self send:message];
    
    textView.text = nil;
    [textView resignFirstResponder];
    return NO;
  }
  
  return YES;
}

-(void)keyboardWasShown:(NSNotification *)notification {
  NSDictionary* info = [notification userInfo];
  CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGRect rect = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height-keyboardSize.height);
  [self.view setFrame:rect];
}

-(void)keyboardWillBeHidden:(NSNotification *)notification {
  [self.view setFrame:[UIScreen mainScreen].applicationFrame];
}

- (void)viewWillAppear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWasShown:)
                                               name:UIKeyboardDidShowNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardDidShowNotification
                                                object:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSUInteger row = (NSUInteger)[indexPath row];
  if ([self.datasource count] < row) {
    return 0;
  }
  NSString *message = [self.datasource objectAtIndex:row];
  
  CGSize constraint = CGSizeMake(self.messageTableView.frame.size.width - (CELL_CONTENT_MARGIN * 2), 20000.0f);
  CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat height = MAX(size.height, 22.0f);
  
  return height + (CELL_CONTENT_MARGIN * 2);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return (NSInteger)[self.datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSUInteger row = (NSUInteger)[indexPath row];
  if ([self.datasource count] < row) {
    return nil;
  }
  
  NSString *cellReuseIdentifier = @"messageCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                  reuseIdentifier:cellReuseIdentifier];
  }
  
  NSString *message = [self.datasource objectAtIndex:row];
  cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
  cell.textLabel.numberOfLines = 0;
  cell.textLabel.text = message;
  cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  return cell;
}

-(void)addMessage:(NSString*)message {
  [self.datasource addObject:message];
  [self.messageTableView reloadData];
  NSIndexPath* ipath = [NSIndexPath indexPathForRow:(NSInteger)[self.datasource count]-1 inSection:0];
  [self.messageTableView scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - SocketIODelegate

- (void) socketIODidConnect:(SocketIO *)socket {
  DLog(@"connected: %@", [socket host]);
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
  DLog(@"disconnected: %@ (error: %@)", [socket host], error.description);
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
  DLog(@"Received message: %@", packet.data);
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet {
  DLog(@"Received json: %@", packet.data);
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
  DLog(@"Received event: %@", packet.data);
  
  NSDictionary *json = [packet dataAsJSON];
  if ([[json valueForKeyPath:@"name"] isEqualToString:@"server_message"]) {
    
    NSString *message = [packet.args objectAtIndex:0];
    [self addMessage:message];
  }
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet {
  DLog(@"message sent: %@", packet.data);
  
  NSDictionary *json = [packet dataAsJSON];
  if ([[json valueForKeyPath:@"name"] isEqualToString:@"server_message"]) {
    NSString *message = [packet.args objectAtIndex:0];
    [self addMessage:message];
  }
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
  DLog(@"Error: %@", error.description);
}


@end
