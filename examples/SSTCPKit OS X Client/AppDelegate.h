#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	SSClient *client;
	IBOutlet NSTextField *textField;
	IBOutlet NSButton *sendButton;
}

- (IBAction)sendButtonClicked:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
