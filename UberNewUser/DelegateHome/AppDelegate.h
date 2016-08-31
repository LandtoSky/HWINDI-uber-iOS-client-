//
//  AppDelegate.h
//  UberNewUser
//
//  Created by Adam - macbook on 27/09/14.
//  Copyright (c) 2015 Hwindi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Google/SignIn.h>
#import <CoreLocation/CoreLocation.h>

#define NOTIFICATION_LOCATION_UPDATE @"Location updated"

@class ProviderDetailsVC;
@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
{
    UIView *viewLoading;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ProviderDetailsVC *vcProvider;

- (NSString *)applicationCacheDirectoryString;
- (BOOL)connected;
-(void) showHUDLoadingView:(NSString *)strTitle;
-(void) hideHUDLoadingView;
-(void)showToastMessage:(NSString *)message;
-(void)showLoadingWithTitle:(NSString *)title;
-(void)hideLoadingView;
-(id)setBoldFontDiscriptor:(id)objc;
-(void) showAlert:(NSString *) alertMessage;

//Location Update.
- (void) startLocationUpdate;
- (void) stopLocationUpdate;
@end
