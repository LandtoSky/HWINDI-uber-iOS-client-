//
//  InviteFriendVC.h
//  HWINDI
//
//  Created by Star Developer on 1/27/16.
//  Copyright © 2016 Hwindi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

@interface InviteFriendVC : BaseVC<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblCode;
@property (weak, nonatomic) IBOutlet UILabel *lblCredit;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;

@end
