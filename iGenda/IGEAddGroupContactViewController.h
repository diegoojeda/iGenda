//
//  IGEAddGroupContactViewController.h
//  iGenda
//
//  Created by Escabia on 19/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGEGroup.h"
#import "IGEAppDelegate.h"

@interface IGEAddGroupContactViewController : UIViewController

@property (strong, nonatomic) IGEAppDelegate *appDelegate;
@property IGEGroup *group;

@end
