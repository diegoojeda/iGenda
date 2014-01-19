//
//  IGELoginViewController.h
//  iGenda
//
//  Created by Máster INFTEL 11 on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "IGEAppDelegate.h"
#import "IGEGroup.h"

@interface IGELoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textUsername;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property NSManagedObjectContext* mno;
- (IBAction)loginClick:(id)sender;
- (IBAction)backgroundClick:(id)sender;
- (IBAction)registerClick: (id) sender;

@end
