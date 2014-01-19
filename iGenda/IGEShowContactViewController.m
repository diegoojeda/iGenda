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
        self.greetingStar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"star.png"]];
    }
    else{
        self.greetingStar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"star_sel.png"]];
    }
}

-(IBAction)callPhone:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:639970861"]];
}

- (IBAction)changeFavorito:(id)sender{//NO ESTA BIEN
    if(_contacto.favorito .intValue == 0){
        _contacto.favorito = [NSNumber numberWithInt:1];
        self.greetingStar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"star_sel.png"]];
        
        //falta guardar
        NSLog(@"HABILITADO \n");
    }
    else{
        _contacto.favorito = [NSNumber numberWithInt:0];
        self.greetingStar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"star.png"]];
        
        //falta guardar
        NSLog(@"DESHABILITADO \n");
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
