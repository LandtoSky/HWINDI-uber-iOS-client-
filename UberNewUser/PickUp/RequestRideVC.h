//
//  RequestRideVC.h
//  HWINDI
//
//  Created by Star Developer on 1/14/16.
//  Copyright © 2016 Hwindi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "BaseVC.h"
@protocol RequestRideDelege<NSObject>
-(void)requestRide:(NSString*)from To:(NSString*)to;
@end

@interface RequestRideVC : BaseVC<UITextFieldDelegate, GMSAutocompleteViewControllerDelegate>
@property (nonatomic, weak) id<RequestRideDelege> delegate;

//View Request
@property (weak, nonatomic) IBOutlet UIView *viewRequest;
@property (weak, nonatomic) IBOutlet UITextField *txtFrom;
@property (weak, nonatomic) IBOutlet UITextField *txtTo;

@property (weak, nonatomic) IBOutlet UILabel *lblLite;
@property (weak, nonatomic) IBOutlet UILabel *lblTaxi;
@property (weak, nonatomic) IBOutlet UILabel *lblTow;
@property (weak, nonatomic) IBOutlet UIView *viewLite;
@property (weak, nonatomic) IBOutlet UIView *viewTaxi;
@property (weak, nonatomic) IBOutlet UIView *viewTow;

//View Estimate
@property (weak, nonatomic) IBOutlet UIView *viewEstimate;
@property (weak, nonatomic) IBOutlet UIButton *btnGotIt;
@property (weak, nonatomic) IBOutlet UILabel *lblFrom;
@property (weak, nonatomic) IBOutlet UILabel *lblTo;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;

@end
