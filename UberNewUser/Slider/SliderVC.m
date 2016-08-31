//
//  SliderVC.m
//  Employee
//
//  Created by Adam - macbook on 19/05/14.
//  Copyright (c) 2014 Adam MacBook Pro 1. All rights reserved.
//

#import "SliderVC.h"
#import "Constants.h"
#import "SWRevealViewController.h"
#import "PickUpVC.h"
#import "CellSlider.h"
#import "HistoryVC.h"
#import "AboutVC.h"
#import "PaymentVC.h"
#import "ProfileVC.h"
#import "PromotionsVC.h"
#import "UIView+Utils.h"
#import "UIImageView+Download.h"
#import "UberStyleGuide.h"
#import "AppDelegate.h"
#import "AFNHelper.h"

@interface SliderVC ()
{
    NSMutableArray *arrMenus,*arrImages;
    NSMutableArray *arrSegueIds;
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSString *strContent;
}

@end

@implementation SliderVC

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tblMenu.backgroundView=nil;
    self.tblMenu.backgroundColor=[UIColor clearColor];
    [self.imgProfilePic applyRoundedCornersFull];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictInfo=[pref objectForKey:PREF_LOGIN_OBJECT];
    
    [self.imgProfilePic downloadFromURL:[dictInfo valueForKey:@"picture"] withPlaceholder:nil];
    
    self.lblName.font=[UberStyleGuide fontRegularBold:16.0f];
    self.lblName.text=[NSString stringWithFormat:@"%@ %@",[dictInfo valueForKey:@"first_name"],[dictInfo valueForKey:@"last_name"]];
    
    arrMenus=[[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"Profile", nil),
              NSLocalizedString(@"RideHistory", nil),NSLocalizedString(@"RideCost", nil),
              NSLocalizedString(@"Feedback", nil),NSLocalizedString(@"Buddies", nil),
              NSLocalizedString(@"Invite", nil),NSLocalizedString(@"About", nil),nil ];
    arrImages=[[NSMutableArray alloc]initWithObjects:@"menu_profile",@"menu_ride_history",@"menu_ride_cost",@"menu_feedback",@"menu_buddies",@"menu_invite",@"menu_about",nil];
    arrSegueIds=[[NSMutableArray alloc]initWithObjects:SEGUE_PROFILE, @"segueToHistory", @"segueToRideCost", @"segueToFeedback", @"segueToBuddies", @"segueToInvite", @"segueToAbout", nil];


    [arrMenus addObject:NSLocalizedString(@"Signout", nil)];
    [arrImages addObject:@"menu_sign_out"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
    
    frontVC=[nav.childViewControllers objectAtIndex:0];
}

#pragma mark -
#pragma mark - UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrMenus count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellSlider *cell=(CellSlider *)[tableView dequeueReusableCellWithIdentifier:@"CellSlider"];
    if (cell==nil) {
        cell=[[CellSlider alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellSlider"];
    }
    cell.lblName.text=[arrMenus objectAtIndex:indexPath.row];
    cell.lblName.font = [UberStyleGuide fontRegular];
    cell.imgIcon.image=[UIImage imageNamed:[arrImages objectAtIndex:indexPath.row]];
    
    
    //[cell setCellData:[arrSlider objectAtIndex:indexPath.row] withParent:self];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[arrMenus objectAtIndex:indexPath.row]isEqualToString:NSLocalizedString(@"Signout", nil)])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Signout", nil) message:NSLocalizedString(@"SignOutMsg", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        alert.tag=100;
        [alert show];

        return;
    }
    //Need TODO
    if(indexPath.row==4)
    {
        return;
    }
   
    [self.revealViewController rightRevealToggle:self];
    
    UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
    
    self.ViewObj=(PickUpVC *)[nav.childViewControllers objectAtIndex:0];
    
    if(self.ViewObj!=nil)
        [self.ViewObj goToSetting:[arrSegueIds objectAtIndex:indexPath.row]];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100)
    {
        if (buttonIndex == 1)
        {
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setObject:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
            [dictParam setObject:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
            
            if([APPDELEGATE connected])
            {
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_LOGOUT withParamData:dictParam withBlock:^(id response, NSError *error)
                 {
                     [APPDELEGATE hideLoadingView];
                     if (response)
                     {
                         [pref removeObjectForKey:PREF_USER_TOKEN];
                         [pref removeObjectForKey:PREF_REQ_ID];
                         [pref removeObjectForKey:PREF_USER_ID];
                         [pref removeObjectForKey:PREF_IS_LOGIN];
                         [pref synchronize];
                         [self.navigationController popToRootViewControllerAnimated:YES];
                         [self.navigationController setNavigationBarHidden:NO];
                     }
                     
                     
                 }];
                
            }
        }
    }
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
