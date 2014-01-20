//
//  IGEAddGroupContactViewController.m
//  iGenda
//
//  Created by Escabia on 19/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEAddGroupContactViewController.h"

@interface IGEAddGroupContactViewController ()

@property (weak, nonatomic) IBOutlet UITextField *grupo;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *okButton;

@end

@implementation IGEAddGroupContactViewController

@synthesize appDelegate;


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"yesh");
    //if (sender != self.okButton) return;
}


// Cuando retrocede...
/*-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        if (self.grupo.text.length > 0)//Validación y almacenado
        {
             NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
             
             self.group = [NSEntityDescription insertNewObjectForEntityForName:@"IGEGroup" inManagedObjectContext:context];
             
             //Esto solo almacena un campo, nombre, lo demas es lo de la persistencia
             appDelegate = [UIApplication sharedApplication].delegate;
             
             self.group.nombre = self.grupo.text;
            

         }
        
    }
    [super viewWillDisappear:animated];
}*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
