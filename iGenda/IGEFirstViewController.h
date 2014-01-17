//
//  IGEFirstViewController.h
//  iGenda
//
//  Created by Máster INFTEL 11 on 15/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGEFirstViewController : UIViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end


