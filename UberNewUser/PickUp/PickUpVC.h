//
//  PickUpVC.h
//  UberNewUser
//
//  Created by Adam - macbook on 27/09/14.
//  Copyright (c) 2014 Hwindi. All rights reserved.
//

#import "BaseVC.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "RequestRideVC.h"

@interface PickUpVC : BaseVC<UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,GMSMapViewDelegate,UIAlertViewDelegate, RequestRideDelege>
{
    NSTimer *timerForCheckReqStatus;
    NSDictionary* aPlacemark;
    NSMutableArray *placeMarkArr;

}

/////// Outlets
@property (weak, nonatomic) IBOutlet UIView *viewGoogleMap;
@property (weak, nonatomic) IBOutlet UIView *viewForMarker;

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnMyLocation;


/////// Actions

- (IBAction)pickMeUpBtnPressed:(id)sender;
- (IBAction)cancelReqBtnPressed:(id)sender;

- (IBAction)myLocationPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPickMeUp;

-(void)goToSetting:(NSString *)str;


///// for driver detail

@property (weak, nonatomic) IBOutlet UIView *viewForDriver;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driverName;
@property (weak, nonatomic) IBOutlet UIImageView *img_driver_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driverRate;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driver_Carname;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driver_CarNumber;


@end
