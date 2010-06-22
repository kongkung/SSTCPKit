//
//  SSTCPKit_iPhone_ClientViewController.m
//  SSTCPKit iPhone Client
//
//  Created by Gustaf Lindqvist on 2010-06-22.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

- (void)setupClient;

@end


@implementation ViewController

- (void)awakeFromNib
{
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
	NSString *val = [textField text];
	if ([val isEqualToString:@""]) {
		return;
	}
	NSString *message = [NSString stringWithFormat:@"%@\n", [textField text]];
	NSData* data = [message dataUsingEncoding: NSASCIIStringEncoding];
	NSLog(@"write message: %@", val);
	[client writeData:data withTimeout:-1 tag:0];
}


@end
