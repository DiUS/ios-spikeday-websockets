//
//  WIMViewController.h
//  WebSocketIM
//
//  Created by Ben Kersten on 9/05/13.
//  Copyright (c) 2013 Dius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"

@interface WIMViewController : UIViewController <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, SocketIODelegate>

@end
