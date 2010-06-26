//
//  ClientConnection.m
//  iPhone Location Simulator
//
//  Created by Gustaf Lindqvist on 2010-01-30.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SSClientConnection.h"
#import "SSServer.h"
#import "AsyncSocket.h"


@implementation SSClientConnection

@synthesize server;
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Init, Dealloc

- (id)initWithAsyncSocket:(AsyncSocket *)aSocket forServer:(SSServer *)aServer
{
	if(self = [super init])
	{
		// Take over ownership of the socket
		self.socket = aSocket;
		self.socket.delegate = self;

		// Ensure pre-buffering is enabled to improve readDataToData performance
		[self.socket enablePreBuffering];
		
		// Store reference to server
		// Note that we do not retain the server. Parents retain their children, children do not retain their parents.
		self.server = aServer;
		
		// Don't anything here.
		// We are currently running on the thread that the server's listen socket is running on.
		// However, the server may place us on a different thread.
		// We should only read/write to our socket on its proper thread.
		// Instead, we'll wait for the call to onSocket:didConnectToHost:port: which will be on the proper thread.
	}
	return self;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(clientConnectionDidConnect:)]) {
		[self.delegate clientConnectionDidConnect: self];
	}
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(clientConnection:didReadData:withTag:)]) {
		[self.delegate clientConnection: self didReadData: data withTag:tag];
	}	
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(clientConnection:didReadString:withTag:)]) {
		NSString *str = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
		[self.delegate clientConnection: self didReadString: str withTag:tag];
	}
}

/*- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(CFIndex)partialLength tag:(long)tag
{}*/

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(clientConnection:didWriteDataWithTag:)]) {
		[self.delegate clientConnection:self didWriteDataWithTag:tag];
	}
}

- (void)dealloc
{
	[_socket setDelegate:nil];
	[_socket disconnect];
	[_socket release];
	[super dealloc];
}

@end
