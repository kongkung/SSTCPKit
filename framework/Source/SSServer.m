#import "SSServer.h"
#import "AsyncSocket.h"
#import "SSClientConnection.h"

#define THREAD_POOL_SIZE 10

@implementation SSServer

@synthesize connections;
@synthesize delegate = _delegate;

- (id) init
{
	if (self = [super init]) 
	{
		_socket = [[AsyncSocket alloc] initWithDelegate: self];
		
		self.connections = [[[NSMutableArray alloc] init] autorelease];
		
		// Initialize an array to reference all the threads
		_runLoops = [[NSMutableArray alloc] initWithCapacity: THREAD_POOL_SIZE];
		
		// Initialize an array to hold the number of connections being processed for each thread
		_runLoopsLoad = [[NSMutableArray alloc] initWithCapacity:THREAD_POOL_SIZE];

		// And register for notifications of closed connections
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(connectionDidDie:)
													 name:SSClientConnectionDidDieNotification
												   object:nil];
		
		// Start threads
		uint i;
		for(i = 0; i < THREAD_POOL_SIZE; i++)
		{
			[NSThread detachNewThreadSelector:@selector(connectionThread:)
									 toTarget:self
								   withObject:[NSNumber numberWithUnsignedInt:i]];
		}
	}
	return self;
}

- (id) initWithDelegate: (id)aDelegate
{
	if (self = [self init]) 
	{
		self.delegate = aDelegate;
	}
	return self;
}

- (void) dealloc
{
	
	[self stop];
	
	[_netService release], _netService = nil;
	[_socket release], _socket = nil;
	[connections release], connections = nil;
	
	[super dealloc];
}

- (BOOL) startWithDomain: (NSString *)domain type: (NSString *)type name: (NSString *) name error: (NSError **)error 
{
	BOOL success;
	int port; 
	
	// set port to 0 to let the kernel give us a port
	success = [_socket acceptOnPort:0 error:error];
	
	if (!success) {
		NSLog(@"Failed to run server: %@ (%@)", [*error localizedDescription], [self hash]);
		return NO;
	} else {
		NSLog(@"Running server on port: %d", [_socket localPort]);
	}
    
    // Now register our service with Bonjour.  
	port = [_socket localPort];
	
	if (success) {
		//_netService = [[NSNetService alloc] initWithDomain:@"" type:@"_poop.tcp." name:name port:port];
		_netService = [[NSNetService alloc] initWithDomain:domain type:type 
													 name:name port:port];
		NSLog(@"%@, initWithDomain: %@ type: %@", _netService, domain, type);
		success = (_netService != nil);
    }
	
    if (success) {
		_netService.delegate = self;
        [_netService publishWithOptions:NSNetServiceNoAutoRename];
        // @todo: fix error handling in -netServiceDidPublish: or -netService:didNotPublish: ...
    }

    if ( success ) {
        assert(port != 0);
    } else {
		NSLog(@"Failed to start Server: %@", *error);
        [self stop];
    }
	
	return success;
}

- (BOOL)stop
{
	// Stop publishing the service via bonjour
	if(_netService) {
		[_netService stop];
		[_netService release];
		_netService = nil;
	}
	
	// This will prevent it from accepting any more connections
	[_socket disconnect];
	
	// Stop all connections the server owns
	@synchronized(connections) {
		[connections removeAllObjects];
	}
	
	return YES;
	
}



- (void)connectionThread:(NSNumber *)threadNum
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@synchronized(_runLoops)
	{
		[_runLoops addObject:[NSRunLoop currentRunLoop]];
		[_runLoopsLoad addObject:[NSNumber numberWithUnsignedInt:0]];
	}
	
	// We can't run the run loop unless it has an associated input source or a timer.
	// So we'll just create a timer that will never fire - unless the server runs for 10,000 years.
	[NSTimer scheduledTimerWithTimeInterval:DBL_MAX target:self selector:@selector(ignore:) userInfo:nil repeats:NO];
	
	// Start the run loop
	[[NSRunLoop currentRunLoop] run];
	
	[pool release];
}


- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	SSClientConnection *newConnection = [[SSClientConnection alloc] initWithAsyncSocket:newSocket forServer:self];
	[self addConnection: newConnection];
	if (self.delegate && [self.delegate respondsToSelector:@selector(server:didAcceptNewClientConnection:)]) {
		[self.delegate server:self didAcceptNewClientConnection:newConnection];
	}
}

/**
 * Called when a new socket is spawned to handle a connection.  This method should return the runloop of the
 * thread on which the new socket and its delegate should operate. If omitted, [NSRunLoop currentRunLoop] is used.
 **/
- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket
{
	// Figure out what thread/runloop to run the new connection on.
	// We choose the thread/runloop with the lowest number of connections.
	
	uint m = 0;
	NSRunLoop *mLoop = nil;
	uint mLoad = 0;
	
	@synchronized(_runLoops)
	{
		mLoop = [_runLoops objectAtIndex:0];
		mLoad = [[_runLoopsLoad objectAtIndex:0] unsignedIntValue];
		
		uint i;
		for(i = 1; i < THREAD_POOL_SIZE; i++)
		{
			uint iLoad = [[_runLoopsLoad objectAtIndex:i] unsignedIntValue];
			
			if(iLoad < mLoad)
			{
				m = i;
				mLoop = [_runLoops objectAtIndex:i];
				mLoad = iLoad;
			}
		}
		
		[_runLoopsLoad replaceObjectAtIndex:m withObject:[NSNumber numberWithUnsignedInt:(mLoad + 1)]];
	}
	
//	NSLog(@"Choosing run loop %u with load %u", m, mLoad);
	
	// And finally, return the proper run loop
	return mLoop;
}

/**
 * This method is automatically called when a HTTPConnection dies.
 * We need to update the number of connections per thread.
 **/
- (void)connectionDidDie:(NSNotification *)notification
{
	// Note: This method is called on the thread/runloop that posted the notification

	@synchronized(_runLoops) {
		unsigned int runLoopIndex = [_runLoops indexOfObject:[NSRunLoop currentRunLoop]];
		
		if(runLoopIndex < [_runLoops count])
		{
			unsigned int runLoopLoad = [[_runLoopsLoad objectAtIndex:runLoopIndex] unsignedIntValue];
			
			NSNumber *newLoad = [NSNumber numberWithUnsignedInt:(runLoopLoad - 1)];
			
			[_runLoopsLoad replaceObjectAtIndex:runLoopIndex withObject:newLoad];
			
			NSLog(@"Updating run loop %u with load %@", runLoopIndex, newLoad);
		}
	}
	
	// Note: This method is called on the thread/runloop that posted the notification
	@synchronized(connections) {
		[connections removeObject:[notification object]];
	}
}

- (void)addConnection:(SSClientConnection *)newConnection
{
	@synchronized(connections) {
		[connections addObject:newConnection];
	}
	[newConnection release];
	
}


#pragma mark -
#pragma mark Bonjour Delegate Methods:

- (void)netServiceDidPublish:(NSNetService *)ns
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(serverIsPublished:)]) {
		[self.delegate serverIsPublished:self];
	}
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
	// TODO: take care of error
	
	NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@)", [ns domain], [ns type], [ns name]);
	NSLog(@"Error Dict: %@", errorDict);
}

#pragma mark -
#pragma mark AsyncSocket delegate methods




@end
