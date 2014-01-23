//
//  IGEPersonasTableViewController.m
//  iGenda
//
//  Created by Máster INFTEL 11 on 16/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEPersonasTableViewController.h"
#import "Contact.h"
#import "IGEAddContactViewController.h"
#import "IGEAppDelegate.h"
#import "Contact.h"
#import "IGEGroup.h"

@interface IGEPersonasTableViewController ()
    
@end

@implementation IGEPersonasTableViewController

@synthesize appDelegate;
@synthesize mySearchBar, myTableView, contacts, filteredContacts, isFiltered;

/** Carga de contactos inicial **/
- (void)loadInitialData {
    //Recuperación de datos
    //if ([self.contacts count] == 0){
    self.contacts = [[NSMutableArray alloc] init];
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGEContact" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];


    NSArray *array = [context executeFetchRequest:request error:&error];

    self.contacts = [(NSArray*)array mutableCopy];
    //}
}


- (IBAction)unwindFromSettings:(UIStoryboardSegue *)segue{
    
}

- (IBAction)unwindFromContactDetailToContactList:(UIStoryboardSegue *)segue{
    
}

- (IBAction)unwindToAddUser:(UIStoryboardSegue *)segue {
    IGEAddContactViewController *source = [segue sourceViewController];
    Contact *item = source.contacto;
    if (item != nil){
        [self.contacts addObject:item];
        [self.tableView reloadData];
    }
}


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
    
    [self loadInitialData];
}


-(void) viewWillAppear:(BOOL)animated{
    [self loadInitialData];
    [self.tableView reloadData];
    [self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //Secciones, correspondientes a las letras del alfabeto que hay contactos
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isFiltered == YES)
    {
        return [filteredContacts count];
    }
    else
    {
        return [self.contacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    Contact* item = [self.contacts objectAtIndex:indexPath.row];
//    
//    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", item.nombre,item.apellido1];
//    NSLog(@"ID CONTACTO: %@", item.id);
//    return cell;
    
    if(isFiltered == YES)
    {
        Contact* item = [filteredContacts objectAtIndex:indexPath.row];

        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", item.nombre,item.apellido1];
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", item.nombre,item.apellido1];
        NSLog(@"ID CONTACTO: %@", item.id);
    }
    else
    {
        Contact* item = [self.contacts objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", item.nombre,item.apellido1];
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", item.nombre,item.apellido1];
        NSLog(@"ID CONTACTO: %@", item.id);
    }
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


/**
    Prepara para la transición de la tabla de contactos a su descripción
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Prepare for segure");
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ContactDescription"]) {
        IGEShowContactViewController *controller = (IGEShowContactViewController *)[[segue destinationViewController] topViewController];
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        if (isFiltered == YES)
        {
            [controller getContact:[filteredContacts objectAtIndex:selectedIndex]];
        }
        else
        {
            [controller getContact:[self.contacts objectAtIndex:selectedIndex]];
        }

    }
}

/**
    Eliminar Contacto
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /** Contexto de core data **/
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error = nil;
    
    /** Añade el contacto a la lista a borrar **/
    IGEContactToDelete *contacto;
    contacto = [NSEntityDescription insertNewObjectForEntityForName:@"IGEContactToDelete" inManagedObjectContext:context];
    contacto.id = [[self.contacts objectAtIndex:indexPath.row] id];
    if (![context save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
    
    /** Elimina contacto de core data **/
    [context deleteObject:[self.contacts objectAtIndex:indexPath.row]];
    
    /** Elimina contacto de memoria **/
    [self.contacts removeObjectAtIndex:indexPath.row];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGESetting" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    IGESetting *set = [[context executeFetchRequest:request error:&error] firstObject];
    if (![(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] modified]){
        [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] setModified:true];
        NSNumber *vers = set.versionAgenda;
        int versint = [vers intValue] + 1;
        set.versionAgenda = [NSNumber numberWithInt:versint];
    }
    
    if (![context save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
    
    [tableView reloadData]; //Recarga la tabla
}

#pragma mark -
#pragma mark UISearchBarDelegate Methods

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length == 0)
    {
        //set our boolean flag
        isFiltered = NO;
    }
    else
    {
        //set our boolean flag
        isFiltered = YES;
        
        //Alloc and init filteredContacts
        filteredContacts =[[NSMutableArray alloc] init];
        
        //Fast enumeration
        for (Contact* contactsName in contacts)
        {
            NSRange contactNameRange = [contactsName.nombre rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if(contactNameRange.location != NSNotFound)
            {
                [filteredContacts addObject:contactsName];
            }
        }
    }
    
    //reload our table view
    [myTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [mySearchBar resignFirstResponder];
}






@end
