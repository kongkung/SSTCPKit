#import <Foundation/Foundation.h>
#import "SSClientBase.h"

@class SSClientConnection;
@class AsyncSocket;

@protocol SSServerDelegate;

#define SSClientConnectionDidDieNotification @"SSClientConnectionDidDie"

@interface SSServer : NSObject 
#if !TARGET_OS_IPHONE
<NSNetServiceDelegate>
#endif
{
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
@property (readonly, nonatomic) NSString *domain;
@property (readonly, nonatomic) NSString *type;
@property (readonly, nonatomic) NSString *name;

@end

@protocol SSServerDelegate<NSObject>

@optional
- (void)serverIsPublished:(SSServer *)aServer;
- (void)server:(SSServer *)aServer didAcceptNewClientConnection:(SSClientConnection *)aClientConnection;
@end
