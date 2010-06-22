//
//  SSTCPKit_OS_X_ServerAppDelegate.m
//  SSTCPKit OS X Server
//
//  Created by Gustaf Lindqvist on 2010-06-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

- (void)setupServer;

@end


@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self setupServer];
}

- (void)dealloc
{
	[lastMessage release];
	[server release];
	[super dealloc];
}

- (void)setupServer
{
	server = [[SSServer alloc] initWithDelegate:self];
	NSError *error;	
	[server startWithDomain:@"" type:@"_SSTCPKitExample._tcp." name:@"SSTCPKitExample" error: &error];
	// take care of error
}


#pragma mark -
#pragma mark SSServer delegate methods

- (void)serverIsPublished:(SSServer *)aServer
{
	NSLog(@"serverIsPublished:");
}

- (void)server:(SSServer *) aServer didAcceptNewClientConnection:(SSClientConnection *)aClientConnection;
{
	NSLog(@"server:didAcceptNewClientConnection: %@", aClientConnection);
	aClientConnection.delegate = self;
}

- (void)clientConnectionDidConnect:(SSClientConnection *)aClientConnection
{
	NSLog(@"clientConnectionDidConnect: %@", aClientConnection);
	[aClientConnection readDataToLineFeedWithTimeout:-1 tag:0];
}

- (void)clientConnection:(SSClientConnection *)clientConnection didReadData: (NSData *)aData withTag: (long)tag
{
	NSLog(@"clientConnectionDidReadData:");
	NSString* message = [[[NSString alloc] initWithData:aData encoding:NSASCIIStringEncoding] autorelease];
	lastMessage.stringValue = message;	
	[clientConnection readDataToLineFeedWithTimeout:-1 tag:0];
}

@end
