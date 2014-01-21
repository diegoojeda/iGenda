//
//  IGEGruposViewController.m
//  iGenda
//
//  Created by Diego Ojeda García on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEGruposViewController.h"
#import "IGEAppDelegate.h"
#import "IGEPersonasFromGrupoViewController.h"

@interface IGEGruposViewController ()



@end

@implementation IGEGruposViewController

@synthesize grupos = _grupos;


- (void) loadInitialData {
    //Recuperación de datos
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGEGroup" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    
    NSArray *array = [context executeFetchRequest:request error:&error];
    self.grupos = [(NSArray*)array mutableCopy];
    
    /** Si no hay grupos creados, añade uno de la base de datos por defecto <Sin Grupo> **/
    if([self.grupos count] == 0){
        IGEGroup *g = [NSEntityDescription insertNewObjectForEntityForName:@"IGEGroup" inManagedObjectContext:context];
        g.nombre = @"<Sin Grupo>";
        [self.grupos addObject:g];
    }
    
    /** Guarda el contexto **/
    [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [self.grupos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"groupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    IGEGroup* item = [self.grupos objectAtIndex:indexPath.row];
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

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Prepare for segue");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"GruposToPersonas"]) {
        IGEPersonasFromGrupoViewController *controller = (IGEPersonasFromGrupoViewController *)[[segue destinationViewController] topViewController];
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        //NSString *groupName = [(IGEGroup *)[self.grupos objectAtIndex:selectedIndex] nombre];
        //NSArray *contactos = [[(IGEGroup *)[self.grupos objectAtIndex:selectedIndex] newRelationship] allObjects];
        
        //NSLog(@"Prepare for Segue ------> %@",[[self.grupos objectAtIndex:selectedIndex] nombre]);
        [controller getGroup:[[self.grupos objectAtIndex:selectedIndex] nombre]];
    }
}

- (IBAction)unwindFromGroupDetailToGroups:(UIStoryboardSegue *)segue{
    NSLog(@"UNWINFROMGROUP");
    //_grupos = nil;
}




/**
 Eliminar Grupo
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /** Contexto de core data **/
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error = nil;
    
    
    if([[[self.grupos objectAtIndex:indexPath.row] nombre]  isEqual: @"<Sin Grupo>"]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Aviso" message:@"No puede eliminar este grupo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else{
        /** Elimina contacto de core data **/
        [context deleteObject:[self.grupos objectAtIndex:indexPath.row]]; //
        
        /** Elimina contacto de memoria **/
        [self.grupos removeObjectAtIndex:indexPath.row];
        
        
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        [tableView reloadData]; //Recarga la tabla
    }
}

- (IBAction)unwindToAddGroup:(UIStoryboardSegue *)segue {
    IGEAddGroupContactViewController *source = [segue sourceViewController];
    IGEGroup *item = source.group;
    if (item != nil){
        [self.grupos addObject:item];
        [self.tableView reloadData];
    }
}

@end





