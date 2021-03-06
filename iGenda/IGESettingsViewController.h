//
//  IGESettingsViewController.h
//  iGenda
//
//  Created by Diego Ojeda García on 18/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGEAppDelegate.h"
#import "IGESetting.h"
#import "Contact.h"
#import "IGEGroup.h"

@interface IGESettingsViewController : UIViewController

@property NSNumber *versDispositivo;
@property NSString *nomUsuario;
@property NSManagedObjectContext *context;

- (IBAction)deleteLoginData:(id)sender;
@property NSMutableString *IP;

@end
