//
//  PromotionsVC.m
//  UberNew
//
//  Created by Adam - macbook on 26/09/14.
//  Copyright (c) 2014 Hwindi. All rights reserved.
//

#import "PromotionsVC.h"
#import "Constants.h"

@interface PromotionsVC ()

@end

@implementation PromotionsVC

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [super setNavBarTitle:TITLE_PROMOTIONS];
    [super setBackBarItem];
    
}

#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
