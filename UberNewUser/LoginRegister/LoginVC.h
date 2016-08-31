//
//  LoginVC.h
//  Uber
//
//  Created by Adam - macbook on 21/06/14.
//  Copyright (c) 2014 Adam MacBook Pro 1. All rights reserved.
//

#import "BaseVC.h"
#import "Reachability.h"

@interface LoginVC : BaseVC<UITextFieldDelegate, UIGestureRecognizerDelegate, GIDSignInUIDelegate, GIDSignInDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;

@property NetworkStatus internetConnectionStatus;
@property(nonatomic,weak)IBOutlet UIScrollView *scrLogin;
@property(nonatomic,weak)IBOutlet UITextField *txtEmail;
@property(nonatomic,weak)IBOutlet UITextField *txtPassword;

- (IBAction)onClickGooglePlus:(id)sender;
- (IBAction)onClickFacebook:(id)sender;

-(IBAction)onClickLogin:(id)sender;

@end
