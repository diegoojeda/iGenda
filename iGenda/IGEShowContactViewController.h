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

@property (strong, nonatomic) IGEAppDelegate *appDelegate;


@property (nonatomic, strong) IBOutlet UILabel *greetingNombre;

- (IBAction) fetchContact;


@end
