//
//  AboutVC.m
//  UberNew
//
//  Created by Adam - macbook on 26/09/14.
//  Copyright (c) 2014 Hwindi. All rights reserved.
//

#import "AboutVC.h"

@interface AboutVC ()

@end

@implementation AboutVC

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavBarTitle:TITLE_ABOUT];
    [self setBackBarItem];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
