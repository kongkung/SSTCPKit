//
//  SSTCPKit_OS_X_ClientAppDelegate.h
//  SSTCPKit OS X Client
//
//  Created by Gustaf Lindqvist on 2010-06-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	SSClient *client;
	IBOutlet NSTextField *textField;
	IBOutlet NSButton *sendButton;
}

- (IBAction)sendButtonClicked:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
