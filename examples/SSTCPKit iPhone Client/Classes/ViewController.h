//
//  SSTCPKit_iPhone_ClientViewController.h
//  SSTCPKit iPhone Client
//
//  Created by Gustaf Lindqvist on 2010-06-22.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
	SSClient *client;
	IBOutlet UITextField *textField;
	IBOutlet UIButton *sendButton;
}

- (IBAction)sendButtonClicked:(id)sender;

@end

