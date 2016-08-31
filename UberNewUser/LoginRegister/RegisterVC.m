//
//  RegisterVC.m
//  Uber
//
//  Created by Adam - macbook on 23/06/14.
//  Copyright (c) 2014 Adam MacBook Pro 1. All rights reserved.
//

#import "RegisterVC.h"

#import "AppDelegate.h"

#import "UIImageView+Download.h"
#import "AFNHelper.h"
#import "Base64.h"
#import "UtilityClass.h"
#import "Constants.h"
#import "UIView+Utils.h"
#import "UberStyleGuide.h"

@interface RegisterVC ()
{
    NSMutableArray *arrForCountry;
    NSString *strImageData,*strForRegistrationType,*strForSocialId,*strForToken,*strForID;
    BOOL isPicAdded;
}

@end

@implementation RegisterVC

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [super setBackBarItem];
    [super setNavBarTitle:TITLE_REGISTER];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    
    [self SetLocalization];
    arrForCountry=[[NSMutableArray alloc]init];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 500)];
    strForRegistrationType=@"manual";
    
    [self customFont];
    
    [self.imgProfilePic applyRoundedCornersFullWithColor:[UIColor whiteColor]];

    self.btnNext.enabled=FALSE;
    isPicAdded=NO;
  
    //For country calling code.
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSMutableArray *arrCountry = [[NSMutableArray alloc] init];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"countrycodes" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    arrCountry = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", countryCode];
    NSArray *results = [arrCountry filteredArrayUsingPredicate:predicate];
    NSArray *code = [results valueForKey:@"phone-code"];
    [self.btnCountryCode setTitle:code[0] forState:UIControlStateNormal];
    
}
-(void)viewWillAppear:(BOOL)animated
{
}

-(void)SetLocalization
{
    NSAttributedString *email = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EMAIL", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtEmail.attributedPlaceholder = email;
    NSAttributedString *password = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PASSWORD", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtPassword.attributedPlaceholder = password;
    NSAttributedString *firstname = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"FIRSTNAME", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtFirstName.attributedPlaceholder = firstname;
    NSAttributedString *lastname = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LASTNAME", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtLastName.attributedPlaceholder = lastname;
    NSAttributedString *number = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NUMBER", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtNumber.attributedPlaceholder=number;
   
}

-(BOOL)validateFields
{
    if(self.txtFirstName.text.length<1)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_FIRST_NAME", nil)];
    }
    else if(self.txtLastName.text.length<1)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_LAST_NAME", nil)];
    }
    else if (![[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text])
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_VALID_EMAIL", nil)];
    }
    else if(self.txtEmail.text.length<1)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_EMAIL", nil)];
    }
    else if(self.txtNumber.text.length<1)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_NUMBER", nil)];
    }
    else if(self.txtNumber.text.length<9)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_NUMBER_MIN", nil)];
    }
    else if(isPicAdded==NO)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_PHOTO", nil)];
    }
    else {
        return true;
    }
    return false;
}

#pragma mark- Custom Font & Localization

-(void)customFont
{
    self.txtFirstName.font=[UberStyleGuide fontRegular];
    self.txtLastName.font=[UberStyleGuide fontRegular];
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.txtPassword.font=[UberStyleGuide fontRegular];

    self.btnNext.titleLabel.font = [UberStyleGuide fontRegularBold];
}

#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextField Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField==self.txtNumber)
    {
        NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0) || [string isEqualToString:@""];
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
   
    if(textField==self.txtFirstName)
        [self.txtLastName becomeFirstResponder];
    else if(textField==self.txtLastName)
        [self.txtEmail becomeFirstResponder];
    else if(textField==self.txtEmail)
        [self.txtPassword becomeFirstResponder];
    else if(textField==self.txtPassword)
        [self.txtNumber becomeFirstResponder];
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onClickNext:(id)sender
{
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    if(![self validateFields]){
        NSLog(@"Incorrect values");
        return;
    }

    NSString *strnumber=[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text, self.txtNumber.text];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSString *strDeviceId=[pref objectForKey:PREF_DEVICE_TOKEN];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setValue:self.txtEmail.text forKey:PARAM_EMAIL];
    [dictParam setValue:self.txtPassword.text forKey:PARAM_PASSWORD];
    [dictParam setValue:self.txtFirstName.text forKey:PARAM_FIRST_NAME];
    [dictParam setValue:self.txtLastName.text forKey:PARAM_LAST_NAME];
    [dictParam setValue:strnumber forKey:PARAM_PHONE];
    [dictParam setValue:strDeviceId forKey:PARAM_DEVICE_TOKEN];
    [dictParam setValue:@"ios" forKey:PARAM_DEVICE_TYPE];

    [dictParam setValue:strForRegistrationType forKey:PARAM_LOGIN_BY];
    
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    [dictParam setObject:countryCode forKey:PARAM_COUNTRY];
    
    if(strForRegistrationType == nil)
    {
        [dictParam setObject:@"manual" forKey:PARAM_LOGIN_BY];
    } else {
        [dictParam setObject:strForRegistrationType forKey:PARAM_LOGIN_BY];
    }
    
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"Registering", nil)];
    UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:self.imgProfilePic.image];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_REGISTER withParamDataImage:dictParam andImage:imgUpload withBlock:^(id response, NSError *error) {
        
        [APPDELEGATE hideLoadingView];
        if (response)
        {
            if([[response valueForKey:@"success"] boolValue])
            {
                [APPDELEGATE showToastMessage:NSLocalizedString(@"REGISTER_SUCCESS", nil)];
                strForID=[response valueForKey:@"id"];
                strForToken=[response valueForKey:@"token"];
               
                [pref setObject:[response valueForKey:@"token"] forKey:PREF_USER_TOKEN];
                [pref setObject:[response valueForKey:@"id"] forKey:PREF_USER_ID];
                [pref setObject:[response valueForKey:@"is_referee"] forKey:PREF_IS_REFEREE];
                
                [pref setObject:self.txtEmail.text forKey:PREF_EMAIL];
                [pref setObject:self.txtPassword.text forKey:PREF_PASSWORD];
                [pref setObject:strForRegistrationType forKey:PREF_LOGIN_BY];
                [pref setBool:YES forKey:PREF_IS_LOGIN];
                [pref synchronize];
                [self performSegueWithIdentifier:SEGUE_APPLY_REFERRAL_CODE sender:self];
                
            }
            else
            {
                NSMutableArray *err=[[NSMutableArray alloc]init];
                err=[response valueForKey:@"error_messages"];
                if (err.count==0)
                {
                    [APPDELEGATE showAlert:[response valueForKey:@"error"]];
                }
                else
                {
                    [APPDELEGATE showAlert:[NSString stringWithFormat:@"%@",[err objectAtIndex:0]]];
                }
            }
            
        }
        NSLog(@"REGISTER RESPONSE --> %@",response);
    }];

}

- (IBAction)onClickCheckBox:(id)sender
{
    BOOL status = self.btnCheckBox.selected;
    self.btnCheckBox.selected = !status;
    self.btnNext.enabled = self.btnCheckBox.selected;
}

- (IBAction)onClickTermsConditions:(id)sender
{
    //[self performSegueWithIdentifier:@"pushToTerms" sender:self];
}
- (IBAction)onClickGoogle:(id)sender {
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    [[GIDSignIn sharedInstance] signIn];
}

- (IBAction)onClickFacebook:(id)sender {
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
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
            [APPDELEGATE showLoadingWithTitle:@"Please wait"];
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, first_name, last_name, picture, email"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if(error){
                    NSLog(@"Failed fetching user information.");
                } else {
                    self.txtEmail.text = [result objectForKey:PREF_EMAIL];
                    self.txtFirstName.text = [result objectForKey:@"first_name"];
                    self.txtLastName.text = [result objectForKey:@"last_name"];
                    strForRegistrationType = @"facebook";
                    strForSocialId = [result objectForKey:PREF_USER_ID];
                    
                    NSURL *pictureURL1 = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [result objectForKey:PREF_USER_ID]]];
                    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL1];
                    UIImage *fbImage = [UIImage imageWithData:imageData];
                    [self.imgProfilePic setImage: fbImage];
                    isPicAdded = YES;
                }
                [APPDELEGATE hideLoadingView];
            }];
        }
    }];
}

- (IBAction)onClickCamera:(id)sender {
    [self takePhoto];
}

- (IBAction)onClickPicture:(id)sender {
    [self chooseFromLibaray];
}
#pragma mark - Action

- (void)chooseFromLibaray
{
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing=YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)takePhoto
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
        imagePickerController.allowsEditing=YES;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    else
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"CAM_NOT_AVAILABLE", nil)];
    }  // Set up the image picker controller and add it to the view
}
#pragma mark - Google Signin
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    NSLog(@"Received Google authentication response! Error: %@", error);
    if (error != nil) {
        // There was an error obtaining the Google OAuth token, display a dialog
        NSString *message = [NSString stringWithFormat:@"There was an error logging into Google: %@",
                             [error localizedDescription]];
        [APPDELEGATE showAlert:message];
    } else {
        self.txtEmail.text = user.profile.email;
        strForRegistrationType=@"google";
        strForSocialId = user.authentication.idToken;
        NSArray* name = [user.profile.name componentsSeparatedByString:@" "];
        self.txtFirstName.text = [name objectAtIndex:0];
        self.txtLastName.text = [name objectAtIndex:1];
    }
}

#pragma mark
#pragma mark - ImagePickerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    //UIImage *resizedImage = [img resizedImageToSize:CGSizeMake(300.0f, 300.0f)];
    
    [self setImage:img];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)setImage:(UIImage *)image
{
    self.imgProfilePic.contentMode = UIViewContentModeScaleAspectFill;
    self.imgProfilePic.clipsToBounds = YES;
    self.imgProfilePic.image=image;
    isPicAdded=YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark - Segue Methods

/*-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_MYTHINGS])
    {
        MyThingsVC *obj=[segue destinationViewController];
        obj.strForToken=strForToken;
        obj.strForID=strForID;
    }
}*/

@end
