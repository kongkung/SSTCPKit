#import <Foundation/Foundation.h>
#import "SSClientBase.h"

@class AsyncSocket;
@class SSServer;

@interface SSClientConnection : SSClientBase {
	SSServer *server;
}

- (id)initWithAsyncSocket:(AsyncSocket *)aSocket forServer:(SSServer *)aServer;

@property (assign, nonatomic) SSServer *server;

@end
