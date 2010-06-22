#import <Foundation/Foundation.h>
#import "SSClientBase.h"

@protocol SSClientDelegate;


@interface SSClient : SSClientBase
#if !TARGET_OS_IPHONE
<NSNetServiceBrowserDelegate, NSNetServiceDelegate>
#endif
{
	
@protected
	BOOL isConnected;
	
@private
    NSNetServiceBrowser *_browser;
    NSNetService *_connectedService;
    NSMutableArray *_services;
	id<SSClientDelegate> _delegate;
}

- (id)initWithServiceOfType:(NSString *)aType inDomain:(NSString *)aDomain delegate: (id)aDelegate;
- (id)initWithServiceOfType:(NSString *)type inDomain:(NSString *)domain;
- (void)disconnect;

@property (readonly, nonatomic) BOOL isConnected;
@property (assign, nonatomic) id delegate;

@end


@protocol SSClientDelegate<NSObject>

@optional
- (void)clientDidConnect:(SSClient *)aClient;
- (void)client:(SSClient *)aClient didReadData:(NSData *)data withTag:(long)tag;
- (void)client:(SSClient *)aClient didWriteDataWithTag:(long)tag;
- (void)client:(SSClient *)aClient gotServiceRemoved:(NSNetService *)aNetService;

@end
