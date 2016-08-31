//
//  ProfileVC.m
//  UberNew
//
//  Created by Adam - macbook on 26/09/14.
//  Copyright (c) 2014 Hwindi. All rights reserved.
//

#import "ProfileVC.h"
#import "UIImageView+Download.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVBase.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "UtilityClass.h"
#import "UIView+Utils.h"
#import "UberStyleGuide.h"
#import "UIImage+ResizeAdditions.h"

@interface ProfileVC ()
{
    NSString *strForUserId,*strForUserToken;
}

@end

@implementation ProfileVC

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setNavBarTitle:TITLE_PROFILE];
    [self setBackBarItem];
    [self setDataForUserInfo];
    
    [self.proPicImgv applyRoundedCornersFull];
    [self customFont];
    [self SetLocalization];
    
    self.txtEmail.enabled = NO;
    self.txtPhone.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated
{

    [self.txtFirstName setTintColor:[UIColor whiteColor]];
    [self.txtLastName setTintColor:[UIColor whiteColor]];
}

-(void)SetLocalization
{
    self.txtFirstName.placeholder=NSLocalizedString(@"FIRST NAME", nil);
    self.txtLastName.placeholder=NSLocalizedString(@"LAST NAME", nil);
    self.txtEmail.placeholder=NSLocalizedString(@"EMAIL", nil);
    self.txtPhone.placeholder=NSLocalizedString(@"PHONE", nil);
    self.txtCurrentPWD.placeholder=NSLocalizedString(@"CURRENT_PASSWORD", nil);
    self.txtNewPWD.placeholder=NSLocalizedString(@"NEW_PASSWORD", nil);
    self.txtConfirmPWD.placeholder=NSLocalizedString(@"CONFIRM_PASSWORD", nil);
    
    /*NSAttributedString *pwd = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"CURRENT_PASSWORD", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtCurrentPWD.attributedPlaceholder = pwd;
    NSAttributedString *npwd = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NEW_PASSWORD", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtNewPWD.attributedPlaceholder = npwd;
    NSAttributedString *cpwd = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"CONFIRM_PASSWORD", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtConfirmPWD.attributedPlaceholder = cpwd;*/

}
-(void)setDataForUserInfo
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictInfo=[pref objectForKey:PREF_LOGIN_OBJECT];
    
    [self.proPicImgv downloadFromURL:[dictInfo valueForKey:@"picture"] withPlaceholder:nil];
    self.txtFirstName.text=[dictInfo valueForKey:@"first_name"];
    self.txtLastName.text=[dictInfo valueForKey:@"last_name"];
    self.txtEmail.text=[dictInfo valueForKey:@"email"];
    self.txtPhone.text=[dictInfo valueForKey:@"phone"];
}
#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark-
#pragma mark - UIButton Action


- (IBAction)selectPhotoBtnPressed:(id)sender
{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    UIActionSheet *actionpass;
    
    actionpass = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SELECT_PHOTO", @""),NSLocalizedString(@"TAKE_PHOTO", @""),nil];
    actionpass.delegate=self;
    [actionpass showInView:window];
}

- (IBAction)updateBtnPressed:(id)sender
{
    if (self.txtNewPWD.text.length > 0 || self.txtConfirmPWD.text.length > 0)
    {
        if ([self.txtNewPWD.text isEqualToString:self.txtConfirmPWD.text])
        {
            [self updateProfile];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Profile Update Fail" message:NSLocalizedString(@"NOT_MATCH_RETYPE",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        [self updateProfile];
    }
    
}
-(void)updateProfile
{
    if([APPDELEGATE connected])
    {
        if([[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text])
        {
            
            [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"EDITING", nil)];
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            strForUserId=[pref objectForKey:PREF_USER_ID];
            strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setValue:self.txtEmail.text forKey:PARAM_EMAIL];
            [dictParam setValue:self.txtFirstName.text forKey:PARAM_FIRST_NAME];
            [dictParam setValue:self.txtLastName.text forKey:PARAM_LAST_NAME];
            [dictParam setValue:self.txtPhone.text forKey:PARAM_PHONE];
            [dictParam setValue:@"" forKey:PARAM_BIO];
            [dictParam setValue:self.txtCurrentPWD.text forKey:PARAM_OLD_PASSWORD];
            [dictParam setValue:self.txtNewPWD.text forKey:PARAM_NEW_PASSWORD];
            [dictParam setValue:strForUserId forKey:PARAM_ID];
            [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
            
            [dictParam setValue:@"" forKey:PARAM_ADDRESS];
            [dictParam setValue:@"" forKey:PARAM_STATE];
            [dictParam setValue:@"" forKey:PARAM_COUNTRY];
            [dictParam setValue:@"" forKey:PARAM_ZIPCODE];
            
            
            UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:self.proPicImgv.image];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_UPADTE withParamDataImage:dictParam andImage:imgUpload withBlock:^(id response, NSError *error) {
                
                [APPDELEGATE hideLoadingView];
                if (response)
                {
                    if([[response valueForKey:@"success"] boolValue])
                    {
                        
                        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                        [pref setObject:response forKey:PREF_LOGIN_OBJECT];
                        [pref synchronize];
                        [self setDataForUserInfo];
                        [APPDELEGATE showToastMessage:NSLocalizedString(@"PROFILE_EDIT_SUCESS", nil)];

                        self.txtConfirmPWD.text=@"";
                        self.txtCurrentPWD.text=@"";
                        self.txtNewPWD.text=@"";
                        // [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[response valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }
                
                NSLog(@"REGISTER RESPONSE --> %@",response);
            }];
        }
        
        
    }
    
    else
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }


}


#pragma mark-
#pragma mark- Custom Font

-(void)customFont
{
    self.txtFirstName.font=[UberStyleGuide fontRegularBold:16.0f];
    self.txtLastName.font=[UberStyleGuide fontRegularBold:16.0f];
    self.txtPhone.font=[UberStyleGuide fontRegular];
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.btnUpdate.titleLabel.font=[UberStyleGuide fontRegularBold];
}

#pragma mark
#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
        {
            [self takePhoto];
        }
            break;
        case 0:
        {
            [self selectPhotos];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark
#pragma mark - Action to Share


- (void)selectPhotos
{
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing=YES;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

-(void)takePhoto
{
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
    imagePickerController.allowsEditing=YES;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

#pragma mark
#pragma mark - ImagePickerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *mediumImage = [img resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(300.0f, 300.0f) interpolationQuality:kCGInterpolationHigh];
    //UIImage *resizedImage = [img resizedImageToSize:CGSizeMake(300.0f, 300.0f)];
    
    [self setImage:mediumImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)setImage:(UIImage *)image
{
    self.proPicImgv.image=image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
