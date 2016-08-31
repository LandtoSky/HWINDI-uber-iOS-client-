//
//  GeneralFeedbackVC.m
//  HWINDI
//
//  Created by Star Developer on 1/26/16.
//  Copyright © 2016 Hwindi. All rights reserved.
//

#import "GeneralFeedbackVC.h"

@interface GeneralFeedbackVC ()

@end

@implementation GeneralFeedbackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavBarTitle:@"Feedback"];
    [self setBackBarItem];
    [self customFont];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)customFont
{
    self.txtFeedback.font=[UberStyleGuide fontRegular];
    self.btnSubmit.titleLabel.font = [UberStyleGuide fontRegularBold];
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
