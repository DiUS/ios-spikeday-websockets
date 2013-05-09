//
//  WIMAppDelegate.h
//  WebSocketIM
//
//  Created by Ben Kersten on 9/05/13.
//  Copyright (c) 2013 Dius. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WIMViewController;

@interface WIMAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) WIMViewController *viewController;
@end
