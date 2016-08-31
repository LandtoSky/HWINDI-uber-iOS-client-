//
//  PaymentVC.m
//  UberNew
//
//  Created by Adam - macbook on 26/09/14.
//  Copyright (c) 2014 Hwindi. All rights reserved.
//

#import "PaymentVC.h"
#import "CardIO.h"
#import <Stripe/Stripe.h>
#import "Stripe.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AFNHelper.h"
#import "UberStyleGuide.h"

@interface PaymentVC ()<CardIOPaymentViewControllerDelegate,STPPaymentCardTextFieldDelegate>
{
    NSString *strForStripeToken,*strForLastFour;

}

@end

@implementation PaymentVC
@synthesize paymentView;
#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [super setNavBarTitle:TITLE_PAYMENT];
    [self setBackBarItem];
    
    paymentView = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(15, 250, 0, 0)];
    paymentView.delegate = self;

    [self.view addSubview:paymentView];
    self.btnAddPayment.enabled=NO;
    
    self.btnAddPayment.titleLabel.font=[UberStyleGuide fontRegularBold];
    self.btnSkip.titleLabel.font = [UberStyleGuide fontRegularBold];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (IBAction)onClickSkip:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)setLocalization
{
    [self.btnAddPayment setTitle:NSLocalizedString(@"ADD PAYMENT", nil) forState:UIControlStateNormal];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.paymentView resignFirstResponder];
}
#pragma mark -
#pragma mark - Actions


- (IBAction)scanBtnPressed:(id)sender
{
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    //scanViewController.appToken = @""; // see Constants.h
    [self presentViewController:scanViewController animated:YES completion:nil];
}

- (IBAction)addPaymentBtnPressed:(id)sender
{
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"Adding cards", nil)];
    
    if (![self.paymentView isValid]) {
        return;
    }
    if (![Stripe defaultPublishableKey]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Publishable Key"
                                                          message:@"Please specify a Stripe Publishable Key in Constants"
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    STPCardParams *params = [[STPCardParams alloc] init];
   
    params.number = self.paymentView.cardNumber;
    params.expMonth = self.paymentView.expirationMonth;
    params.expYear = self.paymentView.expirationYear;
    params.cvc = self.paymentView.cvc;
    [[STPAPIClient sharedClient] createTokenWithCard:params completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
        if (error) {
            [self hasError:error];
        } else {
            [self hasToken:token];
            [self addCardOnServer];
        }
    }];
}

- (void)hasError:(NSError *)error {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (void)hasToken:(STPToken *)token
{
    
    NSLog(@"%@",token.tokenId);
    NSLog(@"%@",token.card.last4);
    
    strForLastFour=token.card.last4;
    strForStripeToken=token.tokenId;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    return;
    
}

#pragma mark -
#pragma mark - CardIOPaymentViewControllerDelegate

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    NSLog(@"Scan succeeded with info: %@", info);
    // Do whatever needs to be done to deliver the purchased items.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"User cancelled scan");
   [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - WS Methods

-(void)addCardOnServer
{
    
    if([APPDELEGATE connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString * strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString * strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        

        
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
    [dictParam setValue:strForUserId forKey:PARAM_ID];
    [dictParam setValue:strForStripeToken forKey:PARAM_STRIPE_TOKEN];
    [dictParam setValue:strForLastFour forKey:PARAM_LAST_FOUR];


    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_ADD_CARD withParamData:dictParam withBlock:^(id response, NSError *error)
     {
        [APPDELEGATE hideLoadingView];
        if(response)
        {
            if([[response valueForKey:@"success"] boolValue])
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Successfully Added your card." delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                alert.tag=100;
                [alert show];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Fail to add your card." delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        
    }];
    }
    else
    {
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        if(alertView.tag==100)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}


@end
