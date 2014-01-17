//
//  IGEPersonasTableViewController.m
//  iGenda
//
//  Created by Máster INFTEL 11 on 16/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEPersonasTableViewController.h"
#import "IGEContact.h"
#import "IGEAddContactViewController.h"


@interface IGEPersonasTableViewController ()

@property NSMutableArray *contacts;



@end

@implementation IGEPersonasTableViewController

/** Carga de contactos inicial **/
- (void)loadInitialData {
    //Fetch from Core Data
    
//    IGEContact *item1 = [[IGEContact alloc] init];
//    item1.nombre = @"Buy milk";
//    [self.contacts addObject:item1];
//    IGEContact *item2 = [[IGEContact alloc] init];
//    item2.nombre = @"Buy eggs";
//    [self.contacts addObject:item2];
//    IGEContact *item3 = [[IGEContact alloc] init];
//    item3.nombre = @"Read a book";
//    [self.contacts addObject:item3];
}

- (IBAction)unwindFromContactDetailToList:(UIStoryboardSegue *)segue{
    
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    IGEAddContactViewController *source = [segue sourceViewController];
    IGEContact *item = source.contacto;
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
    
//    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle:)];
//    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//    [rightRecognizer setNumberOfTouchesRequired:1];
//    [self.view addGestureRecognizer:rightRecognizer];
//    //[rightRecognizer release];
}

- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)sender
{
    //Do moving
    if ( sender.direction == UISwipeGestureRecognizerDirectionRight ){
        NSLog(@" *** SWIPE RIGHT ***");
        
    }
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
    
    IGEContact* item = [self.contacts objectAtIndex:indexPath.row];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO Array marcados para borrar
    [self.contacts removeObjectAtIndex:indexPath.row];
    [tableView reloadData];

}




@end
