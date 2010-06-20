//
//  SSTCPKit_OS_X_ClientAppDelegate.m
//  SSTCPKit OS X Client
//
//  Created by Gustaf Lindqvist on 2010-06-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

- (void)setupClient;

@end


@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self setupClient];
}

- (void)dealloc
{
	[sendButton release];
	[textField release];
	[client release];
	[super dealloc];
}

- (void)setupClient
{
	client = [[SSClient alloc] initWithServiceOfType:@"_SSTCPKitExample._tcp." inDomain:@"" delegate: self];
}

-(void)clientDidConnect:(SSClient *)aClient
{
	[sendButton setEnabled:YES];
}

- (void)sendButtonClicked:(id)sender
{
	NSString *val = [textField stringValue];
	if (![val isEqualToString:@""]) {
		return;
	}
	NSString *message = [NSString stringWithFormat:@"%@\n", [textField stringValue]];
	NSData* data = [message dataUsingEncoding: NSASCIIStringEncoding];
	[client writeData:data withTimeout:-1 tag:0];
}



@end
