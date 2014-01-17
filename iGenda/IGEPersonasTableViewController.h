//
//  IGEPersonasTableViewController.h
//  iGenda
//
//  Created by Máster INFTEL 11 on 16/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGEAppDelegate.h"

@interface IGEPersonasTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IGEAppDelegate *appDelegate;

@end
