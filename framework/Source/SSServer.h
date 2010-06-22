#import <Cocoa/Cocoa.h>
#import "SSClientBase.h"

@class SSClientConnection;
@class AsyncSocket;

@protocol SSServerDelegate;


#define SSClientConnectionDidDieNotification @"SSClientConnectionDidDie"

@interface SSServer : NSObject <NSNetServiceDelegate> {

	NSMutableArray *connections;

@private
	AsyncSocket *_socket;
	NSNetService *_netService;
	NSMutableArray *_runLoops;
	NSMutableArray *_runLoopsLoad;
	id<SSServerDelegate> _delegate;
}

- (id)initWithDelegate: (id)aDelegate;
- (BOOL)startWithDomain: (NSString *)domain type: (NSString *)type name: (NSString *) name error: (NSError **)error;
- (BOOL)stop;
- (void)addConnection:(SSClientConnection *)newConnection;

@property (retain, nonatomic) NSMutableArray *connections;
@property (assign, nonatomic) id delegate;

@end

@protocol SSServerDelegate<NSObject>

@optional
- (void)serverIsPublished:(SSServer *)server;
- (void)server:(SSServer *) server didAcceptNewClientConnection:(SSClientConnection *)clientConnection;
@end
