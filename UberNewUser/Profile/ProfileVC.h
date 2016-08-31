//
//  ProfileVC.h
//  UberNew
//
//  Created by Adam - macbook on 26/09/14.
//  Copyright (c) 2014 Hwindi. All rights reserved.
//

#import "BaseVC.h"

@interface ProfileVC : BaseVC <UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (IBAction)selectPhotoBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *proPicImgv;
@property (weak, nonatomic) IBOutlet UIButton *btnProPic;

@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtCurrentPWD;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPWD;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPWD;

- (IBAction)updateBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdate;

@end
