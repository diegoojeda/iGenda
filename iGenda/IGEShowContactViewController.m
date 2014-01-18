//
//  IGEShowContactViewController.m
//  iGenda
//
//  Created by Escabia on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEShowContactViewController.h"

@interface IGEShowContactViewController ()

@end

@implementation IGEShowContactViewController

@synthesize contacto = _contacto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (IBAction) fetchContact
{
    static NSString *formatString = @"%@%@%@%@%@";
    NSString *fullname = [NSString stringWithFormat:formatString,_contacto.nombre,@" ",_contacto.apellido1,@" ",_contacto.apellido2];
    self.greetingNombre.text = fullname;
    
    self.greetingMovil.text = _contacto.telefono;
    self.greetingEmail.text = _contacto.email;
    self.greetingImage.image=[UIImage imageWithData:_contacto.imagen];
    
    
    if(_contacto.favorito == 0){
        self.greetingStar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"star_none.png"]];
    }
    else{
        self.greetingStar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Blue_Star.png"]];
    }
}

- (IBAction)changeFavorito:(id)sender{
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"IGEContact"
                inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"nombre == %@", _contacto.nombre];
    [request setPredicate:predicate];
    
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    

    
    if (array != nil) {
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        NSLog(@"----> Encontrado %i",count);
        Contact* contactoToEdit = [array objectAtIndex:0]; //Coje el primer contacto favorito
        
        if(_contacto.favorito.intValue == 0){
            _contacto.favorito = [NSNumber numberWithInt:1];
            self.greetingStar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Blue_Star.png"]];
            
            NSLog(@"HABILITADO \n");
        }
        else{
            _contacto.favorito = [NSNumber numberWithInt:0];
            self.greetingStar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"star_none.png"]];
            
            //falta guardar
            NSLog(@"DESHABILITADO \n");
        }
        contactoToEdit.favorito = _contacto.favorito;
        
        /** Guarda el contexto **/
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
    }
    else {
        NSLog(@"Encontrado");
    }
}



- (void)viewDidLoad
{
    [self fetchContact];
    [super viewDidLoad];
}


- (IBAction)unwindFromEditToShowContact:(UIStoryboardSegue *)segue{
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getContact:(Contact *)contacto{
    _contacto = contacto;
}

@end
