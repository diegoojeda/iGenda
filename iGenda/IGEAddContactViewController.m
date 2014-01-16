//
//  IGEAddContactViewController.m
//  iGenda
//
//  Created by Máster INFTEL 11 on 16/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEAddContactViewController.h"

@interface IGEAddContactViewController ()
@property (weak, nonatomic) IBOutlet UITextField *telefono;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *grupo;
@property (weak, nonatomic) IBOutlet UIImageView *foto;
@property (weak, nonatomic) IBOutlet UITextField *apellido2;
@property (weak, nonatomic) IBOutlet UITextField *apellido1;
@property (weak, nonatomic) IBOutlet UITextField *nombre;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@end



@implementation IGEAddContactViewController

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.doneButton) return;
    if (self.nombre.text.length > 0 && self.telefono.text.length >0)
    {
        self.contacto = [[IGEContacto alloc] init];
        self.contacto.nombre = self.nombre.text;
        self.contacto.telefono = self.telefono.text;
        self.contacto.apellido1 = self.apellido1.text;
        self.contacto.apellido2 = self.apellido2.text;
        self.contacto.email = self.email.text;
        self.contacto.grupo = self.grupo.text;
        //self.contacto.foto = self.foto.image;
       
    }
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
