//
//  InviteFriendVC.m
//  HWINDI
//
//  Created by Star Developer on 1/27/16.
//  Copyright © 2016 Hwindi. All rights reserved.
//

#import "InviteFriendVC.h"

@interface InviteFriendVC (){
    NSString *strReferralCode;
}

@end

@implementation InviteFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavBarTitle:@"Invite Friend"];
    [self setBackBarItem];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [self getReferralCode];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getReferralCode
{
    if([APPDELEGATE connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_REFERRAL,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     strReferralCode=[response valueForKey:@"referral_code"];
                     [pref setObject:strReferralCode forKey:PREF_REFERRAL_CODE];
                     [pref synchronize];
                     self.lblCode.text=strReferralCode;
                     self.lblCredit.text=[NSString stringWithFormat:@"$ %@",[response valueForKey:@"balance_amount"]];
                 }
                 else
                 {}
             }
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
    
}
- (IBAction)onClickInvite:(id)sender
{
    //[self shareMail];
    
    NSString *texttoshare = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"My Referral code is", Nil), strReferralCode]; //this is your text string to share
    //UIImage *imagetoshare = @""; //this is your image to share
    NSArray *activityItems = @[texttoshare];
    
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
    [self presentViewController:activityVC animated:TRUE completion:nil];
    
}
-(void)shareMail
{
    if(strReferralCode)
    {
        
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailer=[[MFMailComposeViewController alloc]init ];
            mailer.mailComposeDelegate=self;
            NSString *msg=[NSString stringWithFormat:@"Sign up for Hwindi with my referral code %@, and get the first ride worth $x free!", strReferralCode];
            [mailer setSubject:@"SHARE REFERRAL CODE"];
            [mailer setMessageBody:msg isHTML:NO];
            
            [mailer setDefinesPresentationContext:YES];
            [mailer setEditing:YES];
            [mailer setModalInPopover:YES];
            [mailer setNavigationBarHidden:NO animated:YES];
            [mailer setEdgesForExtendedLayout:UIRectEdgeAll];
            [mailer setExtendedLayoutIncludesOpaqueBars:YES];
            
            
            [self presentViewController:mailer animated:YES completion:nil];
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                            message:@"Your device doesn't support the composer sheet"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            
        }
    }
    else
        
    {
        [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_REFERRAL", nil)];
        
    }
    
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled");
            [self.tabBarController setSelectedIndex:0];
            [self dismissViewControllerAnimated:YES completion:NULL];
            break;
        case MFMailComposeResultSent:
            [self showAlert:@"Mail sent successfully." message:@"Success"];
            [self dismissViewControllerAnimated:YES completion:NULL];
            
            NSLog(@"Mail send successfully");
            break;
        case MFMailComposeResultSaved:
            [self showAlert:@"Mail saved to drafts successfully." message:@"Mail saved"];
            NSLog(@"Mail Saved");
            break;
        case MFMailComposeResultFailed:
            [self showAlert:[NSString stringWithFormat:@"Error:%@.", [error localizedDescription]] message:@"Failed to send mail"];
            NSLog(@"Mail send error : %@",[error localizedDescription]);
            break;
        default:
            break;
    }
}

- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}



@end
