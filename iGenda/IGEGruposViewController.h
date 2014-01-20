//
//  IGEGruposViewController.h
//  iGenda
//
//  Created by Diego Ojeda García on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGEGroup.h"
#import "IGEAddGroupContactViewController.h"

@interface IGEGruposViewController : UITableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong)NSMutableArray *grupos;

@end
