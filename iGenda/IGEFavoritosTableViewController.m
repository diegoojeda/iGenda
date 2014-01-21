//
//  IGEFavoritosTableViewController.m
//  iGenda
//
//  Created by Máster INFTEL 12 on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEFavoritosTableViewController.h"


@interface IGEFavoritosTableViewController ()

@property NSMutableArray *favourites;

@end

@implementation IGEFavoritosTableViewController

- (void)loadFavourites{
    //Recuperación de datos
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGEContact" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    
    NSMutableArray *auxContacts;
    auxContacts=[(NSArray*)array mutableCopy];
    Contact *contact;
    
    
    for (int i=0; i< [auxContacts count]; i++)
    {
        contact = [auxContacts objectAtIndex:i];
        
        NSLog(@"Contacto: %i / Favorito a: %@", i, [contact favorito]);
        
        if ([[contact favorito]  isEqual: @1]) //Favorito (1=true, 0=false)
        {
            [self.favourites addObject:contact];
        }
        
    }
    
    [self.tableView reloadData];
}

- (IBAction)unwindFromFavouriteContactDetailToContactList:(UIStoryboardSegue *)segue{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Prepare for segue favorito");
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"FavouriteContactDescription"]) {
        NSLog(@"Segue favoritos");
        IGEShowContactViewController *controller = (IGEShowContactViewController *)[[segue destinationViewController] topViewController];
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        [controller getContact:[self.favourites objectAtIndex:selectedIndex]];
    }
    
}
///**
// Prepara para la transición de la tabla de contactos a su descripción
// */
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    NSLog(@"Prepare for segure");
//    
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if ([[segue identifier] isEqualToString:@"ContactDescription"]) {
//        IGEShowContactViewController *controller = (IGEShowContactViewController *)[[segue destinationViewController] topViewController];
//        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
//        [controller getContact:[self.contacts objectAtIndex:selectedIndex]];
//    }
//}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.favourites = [[NSMutableArray alloc] init];
    
    [self loadFavourites];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
// Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.favourites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavouritesPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Contact* item = [self.favourites objectAtIndex:indexPath.row];
    cell.textLabel.text = item.nombre;
    
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)unwindFromSettingsToFavs:(UIStoryboardSegue *)segue{
    
}

@end
