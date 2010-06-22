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
	NSLog(@"clientDidConnect:");
	[sendButton setEnabled:YES];
}

- (void)client:(SSClient *)aClient gotServiceRemoved:(NSNetService *)aNetService
{
	NSLog(@"client:gotServiceRemoved:");
	[sendButton setEnabled:NO];
}

- (void)sendButtonClicked:(id)sender
{
	NSString *val = [textField stringValue];
	if ([val isEqualToString:@""]) {
		return;
	}
	NSString *message = [NSString stringWithFormat:@"%@\n", [textField stringValue]];
	NSData* data = [message dataUsingEncoding: NSASCIIStringEncoding];
	NSLog(@"write message: %@", val);
	[client writeData:data withTimeout:-1 tag:0];
}



@end
