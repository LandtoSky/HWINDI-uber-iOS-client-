//
//  RequestRideVC.m
//  HWINDI
//
//  Created by Adam on 1/14/16.
//  Copyright © 2016 Hwindi. All rights reserved.
//

#import "RequestRideVC.h"

@interface RequestRideVC (){
    UIView * coverView;
    BOOL isFrom;
    CLLocationCoordinate2D source, destination;
    NSMutableArray *Places, *Locations;
}

@end

@implementation RequestRideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super setNavBarTitle:@"Request A Ride For Today"];
    [self setBackBarItem];
    [self customFont];
    
    self.viewEstimate.hidden = YES;
    self.viewEstimate.layer.cornerRadius = 5.0f;
    Places = [[NSMutableArray alloc] init];
    Locations = [[NSMutableArray alloc] init];
    
    //Tap gesture on Service type.
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.viewLite.tag = 100;
    self.viewTaxi.tag = 101;
    self.viewTow.tag = 102;
    [self.viewLite addGestureRecognizer:singleTap1];
    [self.viewTaxi addGestureRecognizer:singleTap2];
    [self.viewTow addGestureRecognizer:singleTap3];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self getPlaces];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Click event.
- (IBAction)onClickRequestRide:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
    [self.delegate requestRide:self.txtFrom.text To:self.txtTo.text];
}
- (IBAction)onClickEstimate:(id)sender {
    
    self.lblFrom.text = self.txtFrom.text;
    self.lblTo.text = self.txtTo.text;
    
    CLLocation *start = [[CLLocation alloc] initWithLatitude:source.latitude longitude:source.longitude];
    CLLocation *end = [[CLLocation alloc] initWithLatitude:destination.latitude longitude:destination.longitude];
    CLLocationDistance distance = [start distanceFromLocation:end];
    self.lblDistance.text = [NSString stringWithFormat:@"%f",distance/1000];
    
    if(coverView==nil){
        coverView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.viewRequest addSubview:coverView];
    self.viewEstimate.hidden = NO;
}
- (IBAction)onClickGotIt:(id)sender {
    [coverView removeFromSuperview];
    self.viewEstimate.hidden = YES;
}


-(void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    UIView* view = recognizer.view;
    UIColor *selColor = [UIColor colorWithRed:50.0/255.0f green:120.0/255.0f blue:1.0f alpha:1.0];
    switch (view.tag) {
        case 100: //Lite
            self.lblLite.textColor = selColor;
            self.lblTaxi.textColor = [UIColor lightGrayColor];
            self.lblTow.textColor = [UIColor lightGrayColor];
            break;
        case 101: //Taxi
            self.lblLite.textColor = [UIColor lightGrayColor];
            self.lblTaxi.textColor = selColor;
            self.lblTow.textColor = [UIColor lightGrayColor];
            
            break;
        case 102: //Tow
            self.lblLite.textColor = [UIColor lightGrayColor];
            self.lblTaxi.textColor = [UIColor lightGrayColor];
            self.lblTow.textColor = selColor;
            
            break;
        default:
            break;
    }
}

-(void)customFont
{
    self.lblFrom.font=[UberStyleGuide fontRegular];
    self.lblTo.font=[UberStyleGuide fontRegular];
    self.lblDistance.font=[UberStyleGuide fontRegularBold:16.0f];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == self.txtFrom)
    {
        isFrom = YES;
    }else if(textField ==self.txtTo){
        isFrom = NO;
    }
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}
-(void)getPlaces
{
    //  NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",[strForLatitude floatValue], [strForLongitude floatValue], [strForLatitude floatValue], [strForLongitude floatValue]];
    [Places removeAllObjects];
    [Locations removeAllObjects];
    NSString *url=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?sensor=true&key=AIzaSyCMZ7FAlsFppILtRC9uyWObCXGLs6H8UUg&location=%f,%f&radius=500",[strForCurLatitude floatValue],[strForCurLongitude floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]options: NSJSONReadingMutableContainers error: nil];
    NSMutableArray *result=[JSON valueForKey:@"results"];
    
    for (NSMutableDictionary *dict in result)
    {
        NSMutableDictionary *location=[dict valueForKey:@"geometry"];
        [Locations addObject:[location valueForKey:@"location"]];
        [Places addObject:[dict valueForKey:@"name"]];
    }
    
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
                 
                 if(isFrom){
                     source.latitude=[strLatitude doubleValue];
                     source.longitude=[strLongitude doubleValue];
                 } else {
                     destination.latitude = [strLatitude doubleValue];
                     destination.longitude = [strLongitude doubleValue];
                 }
                 
             }
             
         }
         
     }];
}

#pragma mark - GMSAutocompleteViewControllerDelegate
-(void)viewController:(GMSAutocompleteViewController*)viewController didAutocompleteWithPlace:(GMSPlace *)place
{
    if(isFrom){
        self.txtFrom.text = place.formattedAddress;
    } else{
        self.txtTo.text = place.formattedAddress;
    }
    [self getLocationFromString:place.formattedAddress];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewController:(GMSAutocompleteViewController*)viewController didFailAutocompleteWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)wasCancelled:(GMSAutocompleteViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
