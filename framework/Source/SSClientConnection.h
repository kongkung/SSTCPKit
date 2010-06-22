#import <Foundation/Foundation.h>
#import "SSClientBase.h"

@class AsyncSocket;
@class SSServer;

@protocol SSClientConnectionDelegate;

@interface SSClientConnection : SSClientBase {
	SSServer *server;
	id<SSClientConnectionDelegate> _delegate;
}

- (id)initWithAsyncSocket:(AsyncSocket *)aSocket forServer:(SSServer *)aServer;

@property (assign, nonatomic) SSServer *server;
@property (assign, nonatomic) id delegate;

@end

@protocol SSClientConnectionDelegate<NSObject>

@optional
- (void)clientConnectionDidConnect:(SSClientConnection *)clientConnection;
- (void)clientConnection:(SSClientConnection *)clientConnection didReadData: (NSData *)data withTag: (long)tag;
- (void)clientConnection:(SSClientConnection *)clientConnection didReadString: (NSString *)aString withTag: (long)tag;

@end

