#import <Foundation/Foundation.h>

@class AsyncSocket;

@interface SSClientBase : NSObject {
	AsyncSocket *_socket;
}

- (void)readDataToLineFeedWithTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)readDataToLength:(CFIndex)length withTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)writeData: (NSData *) data withTimeout: (NSTimeInterval)timeout tag: (long)tag;
- (void)writeString: (NSString *) aString withTimeout: (NSTimeInterval)timeout tag: (long)tag;
- (void)readDataToLineFeedWithTimeout:(NSTimeInterval)timeout tag:(long)tag;

@property (retain, nonatomic) AsyncSocket *socket;

@end
