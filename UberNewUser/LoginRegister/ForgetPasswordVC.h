//
//  ForgetPasswordVC.h
//  UberforXOwner
//
//  Created by Deep Gami on 14/11/14.
//  Copyright (c) 2014 Hwindi. All rights reserved.
//

#import "BaseVC.h"

@interface ForgotPasswordVC : BaseVC<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
- (IBAction)btnSendPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@end
