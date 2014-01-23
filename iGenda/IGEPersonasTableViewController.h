//
//  IGEPersonasTableViewController.h
//  iGenda
//
//  Created by Máster INFTEL 11 on 16/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGEAppDelegate.h"
#import "IGEContactToDelete.h"
#import "IGEShowContactViewController.h"

@interface IGEPersonasTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IGEAppDelegate *appDelegate;
@property NSMutableArray *contacts;
@property (strong, nonatomic) NSMutableArray * filteredContacts;
@property BOOL isFiltered;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property UISearchBar *searchBar;
@end
