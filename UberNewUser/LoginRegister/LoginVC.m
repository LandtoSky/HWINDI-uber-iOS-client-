//
//  LoginVC.m
//  Uber
//
//  Created by Adam - macbook on 21/06/14.
//  Copyright (c) 2014 Adam MacBook Pro 1. All rights reserved.
//

#import "LoginVC.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "Constants.h"
#import "UtilityClass.h"
#import "UberStyleGuide.h"
#import "RegisterVC.h"

@interface LoginVC ()
{
    NSString *strSocialId, *strLoginType, *strEmail, *strPassword, *strDeviceToken, *strName;
    AppDelegate *appDelegate;
}

@end

@implementation LoginVC

#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [super setNavBarTitle:NSLocalizedString(@"Sign In Using", nil)];
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    
    [self localizeString];
    [self customFont];
    
    strLoginType=@"manual";
    
    //Reset NSUserDefaults for this app.
    //NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    //Once the user logged in, Go to Pickme directly.
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strEmail = [pref objectForKey:PREF_EMAIL];
    strPassword = [pref objectForKey:PREF_PASSWORD];
    strSocialId = [pref objectForKey:PREF_SOCIAL_UNIQUE_ID];
    strLoginType = [pref objectForKey:PREF_LOGIN_BY];
    
    BOOL isLoggedIn=[pref boolForKey:PREF_IS_LOGIN];
    if(isLoggedIn){
        [self getSignIn];
    }

}
-(void)viewWillAppear:(BOOL)animated
{
}
-(void)localizeString
{
    [self.btnSignIn setTitle:NSLocalizedString(@"SIGN_IN", nil) forState:UIControlStateNormal];
    [self.btnForgotPassword setTitle:NSLocalizedString(@"FORGOT_PASSWORD", nil) forState:UIControlStateNormal];
    
    NSAttributedString *email = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EMAIL", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtEmail.attributedPlaceholder = email;
    NSAttributedString *password = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PASSWORD", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtPassword.attributedPlaceholder = password;
}
-(void)customFont
{
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.txtPassword.font=[UberStyleGuide fontRegular];
    
    self.btnForgotPassword.titleLabel.font = [UberStyleGuide fontRegular];
    self.btnSignIn.titleLabel.font = [UberStyleGuide fontRegularBold];
    self.btnSignUp.titleLabel.font = [UberStyleGuide fontRegularBold];
}

#pragma mark - Google

- (IBAction)onClickGooglePlus:(id)sender
{
    if(![APPDELEGATE connected]){
        [self showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    [[GIDSignIn sharedInstance] signIn];
}
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    NSLog(@"Received Google authentication response! Error: %@", error);
    if (error != nil) {
        // There was an error obtaining the Google OAuth token, display a dialog
        NSString *message = [NSString stringWithFormat:@"There was an error logging into Google: %@",
                             [error localizedDescription]];
        [self showAlert:message];
    } else {
        strEmail = user.profile.email;
        strLoginType=@"google";
        strSocialId = user.userID;
        strName = user.profile.name;
        [self getSignIn];
        
    }
    
}

- (IBAction)onClickFacebook:(id)sender
{
    if(![APPDELEGATE connected]){
        [self showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logInWithReadPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"Facebook login failed. Error: %@", error);
        } else if (result.isCancelled) {
            NSLog(@"Facebook login got cancelled.");
        } else{ //Success
            NSLog(@"Success");
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if(error){
                    NSLog(@"Failed fetching user information.");
                } else {
                    strEmail=[result objectForKey:PARAM_EMAIL];
                    strLoginType=@"facebook";
                    strSocialId=[result objectForKey:PREF_USER_ID];
                    strName = [result objectForKey:PARAM_NAME];
                    
                    [self getSignIn];
                }
            }];
        }
    }];
}

-(IBAction)onClickLogin:(id)sender
{
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];

    if(![APPDELEGATE connected]){
        [self showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    if(self.txtEmail.text.length==0)
    {
        [self showAlert:NSLocalizedString(@"PLEASE_EMAIL", nil)];
        return;
    }
    else if(self.txtPassword.text.length == 0 )
    {
        [self showAlert:NSLocalizedString(@"PLEASE_PASSWORD", nil)];
        return;
    }
    if(![[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text]){
        [self showAlert:NSLocalizedString(@"PLEASE_VALID_EMAIL", nil)];
        return;
    }
    strLoginType = @"manual";
    strEmail = self.txtEmail.text;
    strPassword = self.txtPassword.text;
    [self getSignIn];

}
- (IBAction)onClickCreateAccount:(id)sender {
    [self performSegueWithIdentifier:SEGUE_REGISTER sender:self];
}

#pragma mark - Sign In
-(void)getSignIn
{
    if(strEmail ==nil || strLoginType==nil){
        return;
    }
    
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"LOGIN", nil)];
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    strDeviceToken = [pref objectForKey:PREF_DEVICE_TOKEN];

    NSMutableDictionary *dictParam = [[NSMutableDictionary alloc] init];
    [dictParam setObject:strDeviceToken forKey:PARAM_DEVICE_TOKEN];
    [dictParam setObject:@"ios" forKey:PARAM_DEVICE_TYPE];
    [dictParam setObject:strEmail forKey:PARAM_EMAIL];
    [dictParam setObject:strLoginType forKey:PARAM_LOGIN_BY];
    if ([strLoginType isEqualToString:@"manual"])
    {
        [dictParam setObject:strPassword forKey:PARAM_PASSWORD];
    }
    else
    {
        [dictParam setObject:strSocialId forKey:PARAM_SOCIAL_UNIQUE_ID];
    }
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_LOGIN withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [APPDELEGATE hideLoadingView];
         if (response)
         {
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                 [pref setObject:[response valueForKey:PARAM_TOKEN] forKey:PREF_USER_TOKEN];
                 [pref setObject:[response valueForKey:PARAM_ID] forKey:PREF_USER_ID];
                 [pref setObject:[response valueForKey:PARAM_SOCIAL_UNIQUE_ID] forKey:PREF_SOCIAL_UNIQUE_ID];
                 [pref setObject:[response valueForKey:PARAM_DEVICE_TOKEN] forKey:PREF_DEVICE_TOKEN];
                 
                 [pref setObject:strEmail forKey:PREF_EMAIL];
                 [pref setObject:strPassword forKey:PREF_PASSWORD];
                 [pref setObject:strLoginType forKey:PREF_LOGIN_BY];
                 [pref setBool:YES forKey:PREF_IS_LOGIN];
                 
                 [pref setObject:response forKey:PREF_LOGIN_OBJECT];
                 [pref synchronize];
                 
                 [APPDELEGATE hideLoadingView];
                 [APPDELEGATE showToastMessage:(NSLocalizedString(@"SIGNIN_SUCCESS", nil))];
                 [self performSegueWithIdentifier:SEGUE_SUCCESS_LOGIN sender:self];
             }
             else if(![strLoginType isEqualToString:@"manual"]){
                 [self performSegueWithIdentifier:SEGUE_REGISTER sender:self];
             } else
             {
                 [self showAlert:NSLocalizedString(@"SIGNIN_FAILED", nil)];
             }
         }
         
     }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==self.txtEmail)
    {
        [self.txtPassword becomeFirstResponder];
    }
    else if (textField==self.txtPassword){
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Alert
-(void) showAlert:(NSString *) strAlert_content{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:strAlert_content
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Segue Methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SUCCESS_LOGIN])
    {
        [self.navigationController setNavigationBarHidden:YES];
    }
}
@end
