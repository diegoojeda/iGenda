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

@end

@implementation IGEAddGroupContactViewController

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   /* if (self.grupo.text.length > 0)//Validación y almacenado
    {
        NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        self.group = [NSEntityDescription insertNewObjectForEntityForName:@"IGEGroup" inManagedObjectContext:context];
        
        //Esto solo almacena un campo, nombre, lo demas es lo de la persistencia
        appDelegate = [UIApplication sharedApplication].delegate;
        
        self.group.nombre = self.grupo.text;
        
        NSLog(@"%@ \n", self.grupo.text);
        
        //Conversión imagen UIImage a NSData, formato de la imagen del contacto
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.foto.image)];
        self.contacto.imagen = imageData;
        
        
        [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    }*/
}

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
