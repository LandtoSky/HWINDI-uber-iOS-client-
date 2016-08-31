//
//  GeneralFeedbackVC.h
//  HWINDI
//
//  Created by Star Developer on 1/26/16.
//  Copyright © 2016 Hwindi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface GeneralFeedbackVC : BaseVC

@property (weak, nonatomic) IBOutlet UITextView *txtFeedback;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@end
