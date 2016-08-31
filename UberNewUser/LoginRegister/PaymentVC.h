//
//  PaymentVC.h
//  UberNew
//
//  Created by Adam - macbook on 26/09/14.
//  Copyright (c) 2014 Hwindi. All rights reserved.
//

#import "BaseVC.h"
#import "CardIOPaymentViewControllerDelegate.h"
#import "STPPaymentCardTextField.h"


@interface PaymentVC : BaseVC<UITextFieldDelegate,UIAlertViewDelegate>
{
    
}

///////// Actions


- (IBAction)scanBtnPressed:(id)sender;
- (IBAction)addPaymentBtnPressed:(id)sender;

///////// Property

@property (nonatomic,strong) NSString *strForID;
@property (nonatomic,strong) NSString *strForToken;


///// Outlets
@property(nonatomic, strong) STPPaymentCardTextField *paymentView;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPayment;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;

@end
