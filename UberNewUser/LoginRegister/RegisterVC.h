//
//  RegisterVC.h
//  Uber
//
//  Created by Adam - macbook on 23/06/14.
//  Copyright (c) 2014 Adam MacBook Pro 1. All rights reserved.
//

#import "BaseVC.h"
#import <Google/SignIn.h>

@interface RegisterVC : BaseVC<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, GIDSignInUIDelegate, GIDSignInDelegate>

///// Outlets
@property (weak, nonatomic) IBOutlet UIButton *btnGoogle;
@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnPicture;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePic;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@property (weak, nonatomic) IBOutlet UIButton *btnCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;

- (IBAction)onClickNext:(id)sender;
- (IBAction)onClickCheckBox:(id)sender;

@end
