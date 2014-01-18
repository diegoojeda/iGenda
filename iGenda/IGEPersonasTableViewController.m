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

@property NSMutableArray *contacts;



@end

@implementation IGEPersonasTableViewController

@synthesize appDelegate;

/** Carga de contactos inicial **/
- (void)loadInitialData {
    //Recuperación de datos
    if ([self.contacts count] == 0){
    
        NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
        NSError *error = nil;
    
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGEContact" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
    
    
        NSArray *array = [context executeFetchRequest:request error:&error];

        self.contacts = [(NSArray*)array mutableCopy];
    }
   
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
    self.contacts = [[NSMutableArray alloc] init];
    [self loadInitialData];
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
    return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Contact* item = [self.contacts objectAtIndex:indexPath.row];
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


/**
    Prepara para la transición de la tabla de contactos a su descripción
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ContactDescription"]) {
        IGEShowContactViewController *controller = (IGEShowContactViewController *)[[segue destinationViewController] topViewController];
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        [controller getContact:[self.contacts objectAtIndex:selectedIndex]];
    }
    
}


/**
 Seleccionar Contacto BORRAR LUEGO
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //   indexPath.row;
    appDelegate = [UIApplication sharedApplication].delegate;
    

    appDelegate.seleccionado = [self.contacts objectAtIndex:indexPath.row];
}

/**
    Eliminar Contacto
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error = nil;
    
    [context deleteObject:[self.contacts objectAtIndex:indexPath.row]];
    
    //TODO Array marcados para borrar
    [self.contacts removeObjectAtIndex:indexPath.row];//Elimina contacto de memoria
    
    
    if (![context save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
    
    
    //self.contacto = [NSEntityDescription insertNewObjectForEntityForName:@"IGEContact" inManagedObjectContext:context];

    
    [tableView reloadData]; //Recarga la tabla
}






@end
