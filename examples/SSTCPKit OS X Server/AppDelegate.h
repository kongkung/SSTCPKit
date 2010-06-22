//
//  SSTCPKit_OS_X_ServerAppDelegate.h
//  SSTCPKit OS X Server
//
//  Created by Gustaf Lindqvist on 2010-06-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, SSServerDelegate, SSClientConnectionDelegate> {
    NSWindow *window;
	IBOutlet NSTextField *lastMessage;
	SSServer *server;
}

@property (assign) IBOutlet NSWindow *window;

@end
