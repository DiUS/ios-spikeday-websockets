//
//  WIMViewController.m
//  WebSocketIM
//
//  Created by Ben Kersten on 9/05/13.
//  Copyright (c) 2013 Dius. All rights reserved.
//

#import "WIMViewController.h"


@interface WIMViewController ()
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, strong) UITextView *inputView;
@end

@implementation WIMViewController

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:CGRectZero];
  
  self.messageTableView = [[UITableView alloc] init];
  [self.messageTableView setDelegate:self];
  self.messageTableView.translatesAutoresizingMaskIntoConstraints = NO;
  
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
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_messageTableView]-[_inputView(>=50)]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDict]];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  
  if([text isEqualToString:@"\n"]) {
    // TODO: send action
    
    NSString *message = textView.text;
    DLog(@"message: %@", message);
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


@end
