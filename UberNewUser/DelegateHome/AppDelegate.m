//
//  AppDelegate.m
//  UberNewUser
//
//  Created by Adam - macbook on 27/09/14.
//  Copyright (c) 2014 Hwindi. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "Stripe.h"
#import "Constants.h"
#import "ProviderDetailsVC.h"
#import <GoogleMaps/GoogleMaps.h>

#import "IQKeyboardManager.h"

@implementation AppDelegate{
    MBProgressHUD *hud;
    CLLocationManager * locationManager;
}
@synthesize vcProvider;

#pragma mark - UIApplication Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure Google SignIn
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    [GMSServices provideAPIKey:GOOGLE_MAP_KEY];
    // Override point for customization after application launch.
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    //Keyboard Setup
    IQKeyboardManager *sharedInstance = [IQKeyboardManager sharedManager];
    sharedInstance.shouldResignOnTouchOutside = YES;
    //sharedInstance.keyboardDistanceFromTextField = 50;
    
    //Location Manager Setup
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    //Check for iOS8. Without this, the code will crash with "unknown selector."
    if([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [locationManager requestAlwaysAuthorization];
    }

    if (StripePublishableKey) {
        [Stripe setDefaultPublishableKey:StripePublishableKey];
    }
    // Right, that is the point
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
    {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
   
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    return YES;
}

#pragma mark -
#pragma mark - Push Notification Methods

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

//For interactive notification only
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{

}

-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString* strDeviceToken = [self stringWithDeviceToken:deviceToken];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:strDeviceToken forKey:PREF_DEVICE_TOKEN];
    [prefs synchronize];
    
    NSLog(@"My token is: %@", strDeviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"1212121212" forKey:PREF_DEVICE_TOKEN];
    [prefs synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSMutableDictionary *aps=[userInfo valueForKey:@"aps"];
    NSMutableDictionary *msg=[aps valueForKey:@"message"];
    dictBillInfo=[msg valueForKey:@"bill"];
    is_walker_started=[[msg valueForKey:@"is_walker_started"] intValue];
    is_walker_arrived=[[msg valueForKey:@"is_walker_arrived"] intValue];
    is_started=[[msg valueForKey:@"is_walk_started"] intValue];
    is_completed=[[msg valueForKey:@"is_completed"] intValue];
    is_dog_rated=[[msg valueForKey:@"is_walker_rated"] intValue];
    if (dictBillInfo!=nil)
    {
        if (vcProvider)
        {
            [vcProvider.timerForTimeAndDistance invalidate];
            vcProvider.timerForCheckReqStatuss=nil;
            [vcProvider checkDriverStatus];
        }
        else
        {
            
        }
        
    }
}
-(void)handleRemoteNitification:(UIApplication *)application userInfo:(NSDictionary *)userInfo
{
    NSMutableDictionary *aps=[userInfo valueForKey:@"aps"];
    
    NSMutableDictionary *msg=[aps valueForKey:@"message"];
    dictBillInfo=[msg valueForKey:@"bill"];
    is_walker_started=[[msg valueForKey:@"is_walker_started"] intValue];
    is_walker_arrived=[[msg valueForKey:@"is_walker_arrived"] intValue];
    is_started=[[msg valueForKey:@"is_walk_started"] intValue];
    is_completed=[[msg valueForKey:@"is_completed"] intValue];
    is_dog_rated=[[msg valueForKey:@"is_walker_rated"] intValue];

    if (vcProvider)
    {
        [vcProvider checkDriverStatus];
    }
}
- (NSString*)stringWithDeviceToken:(NSData*)deviceToken
{
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++)
    {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    return [token copy] ;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//For iOS8 and older
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // This is the Facebook or Google+ SDK returning to the app after authentication.
    if ([url.scheme hasPrefix:@"fb"]) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    } else {
        NSDictionary *options=@{UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication, UIApplicationOpenURLOptionsAnnotationKey: annotation};
        return [self application:application openURL:url options:options];
    }
}
//For iOS9
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    if ([url.scheme hasPrefix:@"fb"]) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                           annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    } else {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
}


#pragma mark - Loading View

-(void)showLoadingWithTitle:(NSString *)title
{
    if (viewLoading==nil) {
        viewLoading=[[UIView alloc]initWithFrame:self.window.bounds];
        viewLoading.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];//[UIColor whiteColor];
        //viewLoading.alpha=0.6f;
        
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake((viewLoading.frame.size.width-88)/2, ((viewLoading.frame.size.height-30)/2)-30, 88, 30)];
        img.backgroundColor=[UIColor clearColor];
        
        img.animationImages=[NSArray arrayWithObjects:[UIImage imageNamed:@"loading_1.png"],[UIImage imageNamed:@"loading_2.png"],[UIImage imageNamed:@"loading_3.png"], nil];
        img.animationDuration = 1.0f;
        img.animationRepeatCount = 0;
        [img startAnimating];
        [viewLoading addSubview:img];
        
        UITextView *txt=[[UITextView alloc]initWithFrame:CGRectMake((viewLoading.frame.size.width-250)/2, ((viewLoading.frame.size.height-60)/2)+20, 250, 60)];
        txt.textAlignment=NSTextAlignmentCenter;
        txt.backgroundColor=[UIColor clearColor];
        txt.text=[title uppercaseString];
        txt.font=[UIFont systemFontOfSize:16];
        txt.userInteractionEnabled=FALSE;
        txt.scrollEnabled=FALSE;
        txt.textColor=[UberStyleGuide colorDefault];
        txt.font=[UberStyleGuide fontRegular];
        [viewLoading addSubview:txt];
    }
    
    [self.window addSubview:viewLoading];
    [self.window bringSubviewToFront:viewLoading];
}

-(void)hideLoadingView
{
    if (viewLoading) {
        [viewLoading removeFromSuperview];
        viewLoading=nil;
    }
}

-(void) showHUDLoadingView:(NSString *)strTitle
{
  
    hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.detailsLabelText = [strTitle isEqualToString:@""] ? @"Loading...":strTitle;
    [hud show:YES];
}

-(void) hideHUDLoadingView
{
    [hud hide:YES];
}

-(void)showToastMessage:(NSString *)message
{
    MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:self.window
                                              animated:YES];
    
    // Configure for text only and offset down
    hud1.mode = MBProgressHUDModeText;
    hud1.detailsLabelText = message;
    hud1.margin = 10.f;
    hud1.yOffset = 150.f;
    hud1.removeFromSuperViewOnHide = YES;
    [hud1 hide:YES afterDelay:2.0];
}
#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
#pragma mark -
#pragma mark - Directory Path Methods

- (NSString *)applicationCacheDirectoryString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return cacheDirectory;
}
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark-
#pragma mark- Font Descriptor

-(id)setBoldFontDiscriptor:(id)objc
{
    if([objc isKindOfClass:[UIButton class]])
    {
        UIButton *button=objc;
        button.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:13.0f];
        return button;
    }
    else if([objc isKindOfClass:[UITextField class]])
    {
        UITextField *textField=objc;
        textField.font = [UIFont fontWithName:@"OpenSans-Bold" size:13.0f];
        return textField;
        
        
    }
    else if([objc isKindOfClass:[UILabel class]])
    {
        UILabel *lable=objc;
        lable.font = [UIFont fontWithName:@"OpenSans-Bold" size:13.0f];
        return lable;
    }
    return objc;
}


#pragma mark - Location update
- (void) startLocationUpdate
{
    [locationManager startUpdatingLocation];
}
- (void) stopLocationUpdate
{
    [locationManager stopUpdatingLocation];
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil)
    {
        strForCurLatitude=[NSString stringWithFormat:@"%.8f",currentLocation.coordinate.latitude];//[NSString stringWithFormat:@"%.8f",22.30];//
        strForCurLongitude=[NSString stringWithFormat:@"%.8f",currentLocation.coordinate.longitude];//[NSString stringWithFormat:@"%.8f",70.78];//
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_UPDATE object:nil];
    }
}

#pragma mark alert func
-(void) showAlert:(NSString *) alertMessage{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:alertMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
