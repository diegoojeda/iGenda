//
//  IGEPersonasFromGrupoViewController.m
//  iGenda
//
//  Created by Diego Ojeda García on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEPersonasFromGrupoViewController.h"

@interface IGEPersonasFromGrupoViewController ()

@end

@implementation IGEPersonasFromGrupoViewController

@synthesize nombreGrupo = _nombreGrupo;
@synthesize contactosGrupo = _contactosGrupo;

- (void)loadInitialData {
    self.contactosGrupo = [[NSMutableArray alloc] init];
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGEContact" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"newRelationship.nombre == %@", self.nombreGrupo];
    [request setPredicate:predicate];

    
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    self.contactosGrupo = [(NSArray*)array mutableCopy];
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
    
    self.title = _nombreGrupo;
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_contactosGrupo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"personaFromGrupoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    IGEGroup* item = [_contactosGrupo objectAtIndex:indexPath.row];
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ContactoFromGroup"]) {
        IGEShowContactViewController *controller = (IGEShowContactViewController *)[[segue destinationViewController] topViewController];
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        [controller getContact:[self.contactosGrupo objectAtIndex:selectedIndex]];
    }
}
- (IBAction)unwindFromContactDetailToGroupList:(UIStoryboardSegue *)segue{
}

-(void) getGroup: (NSString *) grupo{
    NSLog(@"Grupo %@",grupo);
    _nombreGrupo = grupo;
}

@end
