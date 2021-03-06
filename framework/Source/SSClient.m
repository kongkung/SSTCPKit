//
//  LSClient.m
//  Location Simulator Demo
//
//  Created by Gustaf Lindqvist on 2010-01-30.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SSClient.h"
#import "AsyncSocket.h"

@interface SSClient ()

- (BOOL)setupWithServiceOfType:(NSString *)aType inDomain:(NSString *)aDomain;

@end

@implementation SSClient

@synthesize isConnected;
@synthesize delegate = _delegate;

- (id)initWithServiceOfType: (NSString *)aType inDomain:(NSString *)aDomain delegate:(id)aDelegate
{
	if (self = [super init]) {
		self.delegate = aDelegate;
		[self setupWithServiceOfType: aType inDomain: aDomain];
	}
	return self;
	
}

- (id)initWithServiceOfType:(NSString *)aType inDomain:(NSString *)aDomain
{
	if (self = [super init]) {
		[self setupWithServiceOfType: aType inDomain: aDomain];
	}
	
	return self;
}

-(void)dealloc {
	if (isConnected) {
		[self disconnect];	
	}
	[_services release], _services = nil;
	[_browser release], _browser = nil;
    [super dealloc];
}

- (BOOL) setupWithServiceOfType:(NSString *)aType inDomain:(NSString *)aDomain
{
    _services = [[NSMutableArray alloc] init];
    _browser = [[NSNetServiceBrowser alloc] init];
    [_browser setDelegate: self];
    [_browser searchForServicesOfType:aType inDomain:aDomain];
	return YES;
}

- (void)disconnect
{
	[_socket disconnect];
	[_socket release];
	isConnected = NO;
}

#pragma mark -
#pragma mark NSNetServiceBrowser delegate methods

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindDomain:(NSString *)domainName moreComing:(BOOL)moreDomainsComing
{}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)moreServicesComing
{
	//	NSLog(@"----netServiceBrowser:didFindService");
	[_services addObject:aService];
	[aService resolveWithTimeout:5.0];
	aService.delegate = self;
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser
{}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didNotSearch:(NSDictionary *)dict
{
	// TODO: take care of error 
	NSLog(@"netServiceBrowser:didNotSearch:");	
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more 
{
	[_services removeObject:aService];
    if ( aService == _connectedService ) {
		[self disconnect];
	}
	if (self.delegate && [self.delegate respondsToSelector:@selector(client:gotServiceRemoved:)]) {
		[self.delegate client: self gotServiceRemoved: aService];
	}
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)netServiceBrowser
{
	NSLog(@"netServiceBrowserDidStopSearch:");	
}

#pragma mark Net Service Browser Delegate Methods


-(void)netServiceDidResolveAddress:(NSNetService *)service 
{	
	NSError *error = nil;
    _socket = [[AsyncSocket alloc] initWithDelegate:self];
    [_socket connectToAddress:service.addresses.lastObject error:&error];
	if (!error) {
//		NSLog(@"Connected to %@", service.addresses.lastObject);
		isConnected = YES;
		_connectedService = service;		
	} else {
		// TODO: take care of error
	}
}

-(void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict 
{
    NSLog(@"Could not resolve: %@", errorDict);
}

- (void)netServiceWillResolve:(NSNetService *)sender
{
	NSLog( @"Attempting to resolve address for %@.", [sender name] );
}

#pragma mark AsyncSocket delegate methods


- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err");
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(clientDidDisconnect:)]) {
		[self.delegate clientDidDisconnect:self];
	}
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(clientDidConnect:)]) {
		[self.delegate clientDidConnect:self];
	}
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(client:didReadData:withTag:)]) {
		[self.delegate client:self didReadData: data withTag: tag];
	}
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(client:didWriteDataWithTag:)]) {
		[self.delegate client:self didWriteDataWithTag:tag];
	}
}


@end
