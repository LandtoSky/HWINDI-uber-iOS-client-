//
//  PickUpVC.m
//  UberNewUser
//
//  Created by Adam - macbook on 27/09/14.
//  Copyright (c) 2014 Hwindi. All rights reserved.
//

#import "PickUpVC.h"
#import "SWRevealViewController.h"
#import "AFNHelper.h"
#import "AboutVC.h"

#import "ProviderDetailsVC.h"
#import "CarTypeCell.h"
#import "CarTypeDataModal.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "UberStyleGuide.h"
#import "EastimateFareVC.h"
#import "UIImageView+Download.h"
#import "UIView+Utils.h"
#import <GoogleMaps/GoogleMaps.h>

@interface PickUpVC ()
{
    NSString *strForUserId,*strForUserToken,*strForLatitude,*strForLongitude,*strForRequestID,*strForDriverLatitude,*strForDriverLongitude,*strForTypeid,*strMinFare,*strPassCap,*strETA, *dist_price,*time_price,*driver_id;
    NSString  *str_price_per_unit_distance, *str_base_distance, *strPaymentOption, *strForDriverList;
    NSMutableArray *arrForInformation, *arrForApplicationType, *arrDriver, *arrType;
    NSMutableDictionary *driverInfo;
    GMSMapView *mapView_;
    CLLocationCoordinate2D source;
    CLLocationCoordinate2D destination;
}

@end

@implementation PickUpVC

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavBarTitle:TITLE_PICKUP];
    [self setMenuBarItem];
    
    if ([CLLocationManager locationServicesEnabled])
    {
        [APPDELEGATE startLocationUpdate];
    } else {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Hwindi Driver -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
    
    [self menuSetup];
    [self checkRequestInProgress];
    [self SetLocalization];

    strForTypeid=@"0";
    strPaymentOption = @"1";
    self.btnCancel.hidden=YES;
    arrForApplicationType=[[NSMutableArray alloc]init];

    driverInfo=[[NSMutableDictionary alloc] init];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    self.viewForDriver.hidden=YES;
    [self.img_driver_profile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    if(![[pref valueForKey:PREF_IS_REFEREE] boolValue])
    {
        //self.navigationController.navigationBarHidden=YES;
        //self.btnMyLocation.hidden=YES;
    }
    else
    {
        self.navigationController.navigationBarHidden=NO;
        [self getAllApplicationType];
        [self checkForAppStatus];
        [self getPagesData];
    }
    [self customFont];
    [self getAddress];
    
    double delayInSec = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSec* NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForCurLatitude doubleValue] longitude:[strForCurLongitude doubleValue] zoom:DEFAULT_ZOOM_LEVEL];
        mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.viewGoogleMap.frame.size.width, self.viewGoogleMap.frame.size.height) camera:camera];
        mapView_.myLocationEnabled = YES;
        mapView_.delegate=self;
        [self.viewGoogleMap addSubview:mapView_];
    });
       
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:NOTIFICATION_LOCATION_UPDATE object:nil];
}
-(void)setMenuBarItem
{
    self.navigationItem.hidesBackButton = YES;
    
    UIButton *btnMenu=[UIButton buttonWithType:UIButtonTypeCustom];
    btnMenu.frame=CGRectMake(0, 0, 18, 22);
    [btnMenu addTarget:self.revealViewController action:@selector(revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
    [btnMenu setTitle:NSLocalizedString(@"MENU", nil) forState:UIControlStateNormal];
    [btnMenu setImage:[UIImage imageNamed:@"btn_menu"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnMenu];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.viewForDriver.hidden=YES;
    self.viewForMarker.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [APPDELEGATE stopLocationUpdate];
    self.navigationController.navigationBarHidden=NO;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)menuSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        revealViewController.rearViewRevealWidth = 240.0f;
        //[self.revealButtonItem addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}
-(void)SetLocalization
{
    [self.btnPickMeUp setTitle:NSLocalizedString(@"PICK ME UP", nil) forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
}

-(void)customFont
{
    self.btnCancel=[APPDELEGATE setBoldFontDiscriptor:self.btnCancel];
    self.btnPickMeUp=[APPDELEGATE setBoldFontDiscriptor:self.btnPickMeUp];
}

-(void)locationUpdated:(NSNotification*) notification
{
    
    if(![APPDELEGATE connected])
    {
        return;
    }
    
    if((strForCurLatitude==nil && strForCurLongitude==nil) ||
       ([strForCurLatitude doubleValue]==0.00 && [strForCurLongitude doubleValue]==0))
    {
        return;
    }
    
    NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
    [dictparam setObject:strForUserId forKey:PARAM_ID];
    [dictparam setObject:strForUserToken forKey:PARAM_TOKEN];
    [dictparam setObject:strForCurLongitude forKey:PARAM_LONGITUDE];
    [dictparam setObject:strForCurLatitude forKey:PARAM_LATITUDE];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_USERLOCATION withParamData:dictparam withBlock:^(id response, NSError *error)
     {
         if([[response valueForKey:@"success"] intValue]==1)
         {
             
         }
     }];
}

#pragma mark- Alert Button Clicked Event

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100)
    {
        if (buttonIndex == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

        }
    }
}

#pragma mark- Google Map Delegate

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    strForLatitude=[NSString stringWithFormat:@"%f",position.target.latitude];
    strForLongitude=[NSString stringWithFormat:@"%f",position.target.longitude];
}

- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{

    if (arrDriver.count>0) {
        [self getETA:[arrDriver objectAtIndex:0]];
    }
    
    [self getAddress];
    [self getProviders];
    
}
-(void)getAddress
{
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",[strForLatitude floatValue], [strForLongitude floatValue], [strForLatitude floatValue], [strForLongitude floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    
    NSDictionary *getRoutes = [JSON valueForKey:@"routes"];
    NSDictionary *getLegs = [getRoutes valueForKey:@"legs"];
    NSArray *getAddress = [getLegs valueForKey:@"end_address"];
    NSLog(@"Address: %@", [getAddress firstObject]);
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark- Searching Method

- (IBAction)Searching:(id)sender
{
    aPlacemark=nil;
    [placeMarkArr removeAllObjects];
  //  CLGeocoder *geocoder;
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    //[dictParam setObject:str forKey:PARAM_ADDRESS];
    //[dictParam setObject:str forKey:@"input"]; // AUTOCOMPLETE API
    [dictParam setObject:@"sensor" forKey:@"false"]; // AUTOCOMPLETE API
    [dictParam setObject:GOOGLE_KEY forKey:PARAM_KEY];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getAddressFromGooglewAutoCompletewithParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if(response)
         {
             //NSArray *arrAddress=[response valueForKey:@"results"];
             NSArray *arrAddress=[response valueForKey:@"predictions"]; //AUTOCOMPLTE API
             
             NSLog(@"AutoCompelete URL: = %@",[[response valueForKey:@"predictions"] valueForKey:@"description"]);
             
             if ([arrAddress count] > 0)
             {
                 
                 placeMarkArr=[[NSMutableArray alloc] initWithArray:arrAddress copyItems:YES];
                 //[placeMarkArr addObject:Placemark]; o
                 
             }
         }
     }];
}

#pragma mark -
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"segueToRequestRide"])
    {
        RequestRideVC *obj=[segue destinationViewController];
        obj.delegate = self;
    }
    if([segue.identifier isEqualToString:SEGUE_ABOUT])
    {
        //AboutVC *obj=[segue destinationViewController];
    }
    else if([segue.identifier isEqualToString:SEGUE_ACCEPT])
    {
        ProviderDetailsVC *obj=[segue destinationViewController];
        obj.strForLatitude=strForLatitude;
        obj.strForLongitude=strForLongitude;
        obj.strForWalkStatedLatitude=strForDriverLatitude;
        obj.strForWalkStatedLongitude=strForDriverLongitude;
    }
    else if ([segue.identifier isEqualToString:@"segueToEastimate"])
    {
        EastimateFareVC *obj=[segue destinationViewController];
        obj.strForLatitude=strForLatitude;
        obj.strForLongitude=strForLongitude;
        obj.strMinFare=strMinFare;
        obj.str_base_distance = str_base_distance;
        obj.str_price_per_unit_distance = str_price_per_unit_distance;
    }
}

-(void)goToSetting:(NSString *)str
{
    [self performSegueWithIdentifier:str sender:self];
}

#pragma mark -
#pragma mark - UIButton Action


- (IBAction)requestBtnPressed:(id)sender
{
    if ([strForTypeid isEqualToString:@"0"]||strForTypeid==nil)
    {
        strForTypeid=@"1";
    }
    if(![strForTypeid isEqualToString:@"0"])
    {
        if(((strForLatitude==nil)&&(strForLongitude==nil))
           ||(([strForLongitude doubleValue]==0.00)&&([strForLatitude doubleValue]==0)))
        {
            [APPDELEGATE showToastMessage:NSLocalizedString(@"NOT_VALID_LOCATION", nil)];
        }
        else
        {
            
            [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"REQUESTING", nil)];
            
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            strForUserId=[pref objectForKey:PREF_USER_ID];
            strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setValue:strForLatitude forKey:PARAM_LATITUDE];
            [dictParam setValue:strForLongitude  forKey:PARAM_LONGITUDE];
            //[dictParam setValue:@"22.3023117"  forKey:PARAM_LATITUDE];
            //[dictParam setValue:@"70.7969645"  forKey:PARAM_LONGITUDE];
            [dictParam setValue:@"1" forKey:PARAM_DISTANCE];
            [dictParam setValue:strForUserId forKey:PARAM_ID];
            [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
            [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
            [dictParam setValue:@"1" forKey:PARAM_PAYMENT_OPT];
            
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_CREATE_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 [APPDELEGATE hideLoadingView];
                 NSLog(@"%@, %@", FILE_CREATE_REQUEST, response);
                 
                 if (response)
                 {
                     if([[response valueForKey:@"success"]boolValue])
                     {
                         NSMutableDictionary *walker=[response valueForKey:@"walker"];
                         [self showDriver:walker];
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         
                         strForRequestID=[response valueForKey:@"request_id"];
                         [pref setObject:strForRequestID forKey:PREF_REQ_ID];
                         [self setTimerToCheckDriverStatus];
                         
                         [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"CONTACTING_SERVICE_PROVIDER", nil)];
                         [self.btnCancel setHidden:NO];
                         [self.viewForDriver setHidden:NO];
                         [APPDELEGATE.window addSubview:self.btnCancel];
                         [APPDELEGATE.window bringSubviewToFront:self.btnCancel];
                         [APPDELEGATE.window addSubview:self.viewForDriver];
                         [APPDELEGATE.window bringSubviewToFront:self.viewForDriver];
                     }
                     else
                     {
                         NSLog(@"Error: %@", [response valueForKey:@"error"]);
                         [APPDELEGATE showAlert:[response valueForKey:@"error"]];
                     }
                 }
                 
                 
             }];
        }
        
    }
    else{
        [APPDELEGATE showToastMessage:NSLocalizedString(@"SELECT_TYPE", nil)];
    }
}

- (IBAction)pickMeUpBtnPressed:(id)sender
{
    [self performSegueWithIdentifier:SEGUE_REQUEST_RIDE sender:self];

}

- (IBAction)cancelReqBtnPressed:(id)sender
{
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    [APPDELEGATE hideLoadingView];
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"CANCLEING", nil)];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    
    [dictParam setValue:strForUserId forKey:PARAM_ID];
    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
    [dictParam setValue:strReqId forKey:PARAM_REQUEST_ID];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_CANCEL_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if([[response valueForKey:@"success"]boolValue])
             {
                 [timerForCheckReqStatus invalidate];
                 timerForCheckReqStatus=nil;
                 [APPDELEGATE hideLoadingView];
                 self.btnCancel.hidden=YES;
                 self.viewForDriver.hidden=YES;
                 [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                 
             }
             else
             {}
         }
     }];
}

- (IBAction)myLocationPressed:(id)sender
{
    if ([CLLocationManager locationServicesEnabled])
    {
        CLLocationCoordinate2D coor;
        coor.latitude=[strForCurLatitude doubleValue];
         coor.longitude=[strForCurLongitude doubleValue];
         GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:DEFAULT_ZOOM_LEVEL];
         [mapView_ animateWithCameraUpdate:updatedCamera];
    }
   
}

#pragma mark -
#pragma mark - Custom WS Methods

-(void)getAllApplicationType
{
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:FILE_APPLICATION_TYPE withParamData:nil withBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if([[response valueForKey:@"success"]boolValue])
             {
                 NSMutableArray *arr=[[NSMutableArray alloc]init];
                 [arr addObjectsFromArray:[response valueForKey:@"types"]];
                 arrType=[response valueForKey:@"types"];
                 for(NSMutableDictionary *dict in arr)
                 {
                     CarTypeDataModal *obj=[[CarTypeDataModal alloc]init];
                     obj.id_=[dict valueForKey:@"id"];
                     obj.name=[dict valueForKey:@"name"];
                     obj.icon=[dict valueForKey:@"icon"];
                     obj.is_default=[dict valueForKey:@"is_default"];
                     obj.price_per_unit_time=[dict valueForKey:@"price_per_unit_time"];
                     obj.price_per_unit_distance=[dict valueForKey:@"price_per_unit_distance"];
                     obj.base_price=[dict valueForKey:@"base_price"];
                     obj.isSelected=NO;
                     [arrForApplicationType addObject:obj];
                 }

             }
             
         }
         
     }];
    
}
-(void)setTimerToCheckDriverStatus
{
    if (timerForCheckReqStatus) {
        [timerForCheckReqStatus invalidate];
        timerForCheckReqStatus = nil;
    }
    
     timerForCheckReqStatus = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkForRequestStatus) userInfo:nil repeats:YES];
}
-(void)checkForAppStatus
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
  //  [pref removeObjectForKey:PREF_REQ_ID];
    NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
    
    if(strReqId!=nil)
    {
        [self checkForRequestStatus];
    }
    else
    {
        [self RequestInProgress];
    }
}

-(void)checkForRequestStatus
{
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }

    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
    
    NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
     {
         if (response)
         {
             
             if([[response valueForKey:@"success"]boolValue] && [[response valueForKey:@"confirmed_walker"] integerValue]!=0)
             {
                 NSLog(@"GET REQ--->%@",response);
                 NSString *strCheck=[response valueForKey:@"walker"];
                 
                 if(strCheck)
                 {
                     self.btnCancel.hidden=YES;
                     self.viewForDriver.hidden=YES;
                     //[self.btnCancel removeFromSuperview];
                     
                     [APPDELEGATE hideLoadingView];
                     NSMutableDictionary *dictWalker=[response valueForKey:@"walker"];
                     strForDriverLatitude=[dictWalker valueForKey:@"latitude"];
                     strForDriverLongitude=[dictWalker valueForKey:@"longitude"];
                     if ([[response valueForKey:@"is_walker_rated"]integerValue]==1)
                     {
                         [pref removeObjectForKey:PREF_REQ_ID];
                         return ;
                     }
                     
                     ProviderDetailsVC *vcFeed = nil;
                     for (int i=0; i<self.navigationController.viewControllers.count; i++)
                     {
                         UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
                         if ([vc isKindOfClass:[ProviderDetailsVC class]])
                         {
                             vcFeed = (ProviderDetailsVC *)vc;
                         }
                         
                     }
                     if (vcFeed==nil)
                     {
                         [timerForCheckReqStatus invalidate];
                         timerForCheckReqStatus=nil;
                         [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"PLEASE_WAIT", nil)];
                         [self performSegueWithIdentifier:SEGUE_ACCEPT sender:self];
                     }else
                     {
                         [self.navigationController popToViewController:vcFeed animated:NO];
                     }
                 }
                 
             }
             if([[response valueForKey:@"confirmed_walker"] intValue]==0 && [[response valueForKey:@"status"] intValue]==1)
             {
                 [APPDELEGATE hideLoadingView];
                 [timerForCheckReqStatus invalidate];
                 timerForCheckReqStatus=nil;
                 NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                 [pref removeObjectForKey:PREF_REQ_ID];
                 
                 [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_WALKER", nil)];
                 [APPDELEGATE hideLoadingView];
                 self.btnCancel.hidden=YES;
                 self.viewForDriver.hidden=YES;
                 
             }
             else
             {
                 driverInfo=[response valueForKey:@"walker"];
                 [self showDriver:driverInfo];
             }
         }
         
         else
         {}
     }];

}
-(void)checkRequestInProgress
{
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    
    NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_GET_REQUEST_PROGRESS,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
     {
         [APPDELEGATE hideLoadingView];
         if (response)
         {
             if([[response valueForKey:@"success"]boolValue])
             {
                 
             }
             else
             {}
         }
     }];
}
-(void)RequestInProgress
{
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    
    NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_GET_REQUEST_PROGRESS,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
     {
         [APPDELEGATE hideLoadingView];
         if (response)
         {
             if([[response valueForKey:@"success"]boolValue])
             {
                 NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                 //                     NSMutableDictionary *charge_details=[response valueForKey:@"charge_details"];
                 //                     dist_price=[charge_details valueForKey:@"distance_price"];
                 //                     [pref setObject:dist_price forKey:PRFE_PRICE_PER_DIST];
                 //                     time_price=[charge_details valueForKey:@"price_per_unit_time"];
                 //                     [pref setObject:[charge_details valueForKey:@"price_per_unit_time"] forKey:PRFE_PRICE_PER_TIME];
                 //                     self.lblRate_DistancePrice.text=[NSString stringWithFormat:@"$ %@",dist_price];
                 //                     self.lblRate_TimePrice.text=[NSString stringWithFormat:@"$ %@",time_price];
                 
                 [pref setObject:[response valueForKey:@"request_id"] forKey:PREF_REQ_ID];
                 [pref synchronize];
                 [self checkForRequestStatus];
             }
             else
             {}
         }
         
         
     }];

}

-(void)getPagesData
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }

    NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@",FILE_PAGE,PARAM_ID,strForUserId];
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
     {
         NSLog(@"%@: %@", pageUrl, response);
         [APPDELEGATE hideLoadingView];
         
         if (response)
         {
             arrPage=[response valueForKey:@"informations"];
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 //   [APPDELEGATE showToastMessage:@"Requset Accepted"];
             }
         }
         
     }];
}

-(void)getProviders
{
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    
    [dictParam setValue:strForUserId forKey:PARAM_ID];
    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
    [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
    [dictParam setValue:strForLatitude forKey:@"usr_lat"];
    [dictParam setValue:strForLongitude forKey:@"user_long"];
    
    
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_GET_PROVIDERS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         NSLog(@"%@, %@", FILE_GET_PROVIDERS, response);
         if (response)
         {
             // [arrDriver removeAllObjects];
             arrDriver=[response valueForKey:@"walker_list"];
             [self showProvider];
             
         }
         else
         {
             arrDriver=[[NSMutableArray alloc] init];
             [self showProvider];
         }
     }];
}
-(void)showProvider
{
   [mapView_ clear];
    BOOL is_first=YES;
    for (int i=0; i<arrDriver.count; i++)
    {
        NSDictionary *dict=[arrDriver objectAtIndex:i];
        NSString *strType=[NSString stringWithFormat:@"%@",[dict valueForKey:@"type"]];
        if ([strForTypeid isEqualToString:strType])
        {
            GMSMarker *driver_marker;
            driver_marker = [[GMSMarker alloc] init];
            driver_marker.position = CLLocationCoordinate2DMake([[dict valueForKey:@"latitude"]doubleValue],[[dict valueForKey:@"longitude"]doubleValue]);
            driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
            driver_marker.map = mapView_;
            if (is_first)
            {
                [self getETA:dict];
                is_first=NO;
            }
        }
     }
    is_first=YES;
}

-(void)getETA:(NSDictionary *)dict
{
    CLLocationCoordinate2D scorr=CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
    CLLocationCoordinate2D dcorr=CLLocationCoordinate2DMake([[dict valueForKey:@"latitude"]doubleValue], [[dict valueForKey:@"longitude"]doubleValue]);
    [self calculateRoutesFrom:scorr to:dcorr];
    
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=%@",saddr,daddr,GOOGLE_KEY];
    
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError* error = nil;
    NSData *data = [[NSData alloc]initWithContentsOfURL:apiUrl];
    
    NSDictionary *json =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if ([[json objectForKey:@"status"]isEqualToString:@"REQUEST_DENIED"] || [[json objectForKey:@"status"] isEqualToString:@"OVER_QUERY_LIMIT"] || [[json objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"])
    {
        
    }
    
    return nil;
}
-(void)showDriver:(NSMutableDictionary *)walker
{
    if([driver_id integerValue]!=[[walker valueForKey:@"id"]integerValue ])
    
    //if(![driver_id isEqualToString:[NSString stringWithFormat:@"%@", [walker valueForKey:@"id"]]])
    {
             driver_id=[walker valueForKey:@"id"];
             self.lbl_driverName.text=[NSString stringWithFormat:@"%@ %@",[walker valueForKey:@"first_name"],[walker valueForKey:@"last_name"]];
             self.lbl_driverRate.text=[NSString stringWithFormat:@"%@", [walker valueForKey:@"rating"]];
             self.lbl_driver_Carname.text=[NSString stringWithFormat:@"%@",[walker valueForKey:@"car_model"]];
             self.lbl_driver_CarNumber.text=[NSString stringWithFormat:@"%@",[walker valueForKey:@"car_number"]];
             [self.img_driver_profile downloadFromURL:[walker valueForKey:@"picture"] withPlaceholder:nil];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrForApplicationType.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CarTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cartype" forIndexPath:indexPath];
   
    NSDictionary *dictType=[arrForApplicationType objectAtIndex:indexPath.row];
    if (strForTypeid==nil || [strForTypeid isEqualToString:@"0"])
    {
        if ([[dictType valueForKey:@"is_default"]intValue]==1)
        {
            for(CarTypeDataModal *obj in arrForApplicationType)
            {
                obj.isSelected = NO;
            }
            CarTypeDataModal *obj=[arrForApplicationType objectAtIndex:indexPath.row];
            obj.isSelected = YES;
            if (arrDriver.count>0) {
                [self getETA:[arrDriver objectAtIndex:0]];
            }
            
            NSDictionary *dict=[arrType objectAtIndex:indexPath.row];
            strMinFare=[NSString stringWithFormat:@"%@",[dict valueForKey:@"base_price"]];
            strPassCap=[NSString stringWithFormat:@"%@",[dict valueForKey:@"max_size"]];
            str_base_distance = [NSString stringWithFormat:@"%@",[dict valueForKey:@"base_distance"]];
            str_price_per_unit_distance =  [NSString stringWithFormat:@"%f",[[dict valueForKey:@"price_per_unit_distance"  ] floatValue]];

            strForTypeid=[NSString stringWithFormat:@"%@",obj.id_];
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            [pref setObject:strMinFare forKey:PREF_FARE_AMOUNT];
            [pref synchronize];
        }
    }
    
    [cell setCellData:[arrForApplicationType objectAtIndex:indexPath.row]];
    
  //  cell.imgType.layer.masksToBounds = YES;
 //   cell.imgType.layer.opaque = NO;
//    cell.imgType.layer.cornerRadius=18;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    for(CarTypeDataModal *obj in arrForApplicationType) {
        obj.isSelected = NO;
    }
    CarTypeDataModal *obj=[arrForApplicationType objectAtIndex:indexPath.row];
    obj.isSelected = YES;
    NSDictionary *dict=[arrType objectAtIndex:indexPath.row];
    strMinFare=[NSString stringWithFormat:@"%@",[dict valueForKey:@"min_fare"]];
    strPassCap=[NSString stringWithFormat:@"%@",[dict valueForKey:@"max_size"]];
    str_base_distance = [NSString stringWithFormat:@"%@",[dict valueForKey:@"base_distance"]];
    //str_price_per_unit_distance =  [NSString stringWithFormat:@"%@",[dict valueForKey:@"price_per_unit_distance"]];
    str_price_per_unit_distance =  [NSString stringWithFormat:@"%f",[[dict valueForKey:@"price_per_unit_distance"  ] floatValue]];
    if ([strForTypeid intValue] !=[obj.id_ intValue])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        [pref setObject:strMinFare forKey:PREF_FARE_AMOUNT];
        [pref synchronize];
    }
    strForTypeid=[NSString stringWithFormat:@"%@",obj.id_];
   
    [self showProvider];
}


-(void)getLocationFromString:(NSString *)str
{
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setObject:str forKey:PARAM_ADDRESS];
    [dictParam setObject:GOOGLE_KEY forKey:PARAM_KEY];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getAddressFromGooglewithParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if(response)
         {
             NSArray *arrAddress=[response valueForKey:@"results"];
            
             if ([arrAddress count] > 0)
             {
                
                 NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
             
                 NSString * strLatitude=[dictLocation valueForKey:@"lat"];
                 NSString * strLongitude=[dictLocation valueForKey:@"lng"];
                 
                 
                 source.latitude=[strLatitude doubleValue];
                 source.longitude=[strLongitude doubleValue];
                 
                
             }
             
         }
         
     }];
}


#pragma mark -

-(void)createService
{

    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
        
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"REQUESTING", nil)];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
    [dictParam setObject:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_APPLY_REFERRAL withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [APPDELEGATE hideLoadingView];
         if (response)
         {
             if([[response valueForKey:@"success"]boolValue])
             {
                 NSLog(@"%@",response);
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                     [pref setObject:[response valueForKey:@"is_referee"] forKey:PREF_IS_REFEREE];
                     [pref synchronize];
                     self.btnMyLocation.hidden=NO;
                     self.navigationController.navigationBarHidden=NO;

                     [self getAllApplicationType];
                     [self menuSetup];
                     [self checkForAppStatus];
                     [self getPagesData];
                     [self getProviders];
                 }
             }

         }
     }];

    
}
#pragma mark RequestRideDelegate
-(void)requestRide:(NSString*)from To:(NSString*)to{
    [self requestBtnPressed:nil];
}

@end

