//
//  IGEShowContactViewController.h
//  iGenda
//
//  Created by Escabia on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGEAppDelegate.h"


@interface IGEShowContactViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *greetingNombre;

@property Contact *contacto;


- (IBAction) fetchContact;


- (void) getContact:(Contact *)contacto;

@end
