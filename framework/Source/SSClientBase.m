#import "SSClientBase.h"
#import "AsyncSocket.h"

@implementation SSClientBase

@synthesize socket = _socket;

- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag
{
	[self.socket writeData:data withTimeout:timeout tag:tag];	
}

- (void)writeString:(NSString *)aString withTimeout:(NSTimeInterval)timeout tag:(long)tag
{
	[self writeData:[aString dataUsingEncoding: NSASCIIStringEncoding] withTimeout:timeout tag:tag];	
}

- (void)readDataToLength:(CFIndex)length withTimeout:(NSTimeInterval)timeout tag:(long)tag
{
	[self.socket readDataToLength:length withTimeout:timeout tag:tag];
}

- (void)readDataToLineFeedWithTimeout:(NSTimeInterval)timeout tag:(long)tag
{
	[self.socket readDataToData: [AsyncSocket LFData] withTimeout: timeout tag: tag];
}


@end
