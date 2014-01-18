//
//  IGELoginViewController.m
//  iGenda
//
//  Created by Máster INFTEL 11 on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGELoginViewController.h"
#import "SBJson.h"

@interface IGELoginViewController ()

@end

@implementation IGELoginViewController

@synthesize mno = _mno;

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

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}


- (IBAction)loginClick:(id)sender
{
    NSInteger success = 0;
    if([[self.textUsername text] isEqualToString:@""] || [[self.textPassword text] isEqualToString:@""] ) {
        [self alertStatus:@"Please enter Email and Password" :@"Sign in Failed!" :0];
    }
    else {
        NSHTTPURLResponse  *response = nil;
        NSError *error;
        NSString* username = [[NSString alloc]initWithString:[self.textUsername text]];
        NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://localhost:8080/iGenda/webresources/servicios.usuario/"];
        [url appendString:username];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
        [request setHTTPMethod: @"GET"];
        NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"GET enviado");
        NSString *str = [[NSString alloc]initWithData:response1 encoding:NSUTF8StringEncoding];
        if ([str length] > 0){
            NSLog(@"LOGIN SUCCESFUL");
            //En el NSString str está almacenado el JSON, es genial =)
            [self cargarContactos:username];
            success = 1;
        }
        else {
            NSLog(@"FAIL");
        }
    }
    if (success) {
        [self performSegueWithIdentifier:@"login_success" sender:self];
    }
}

- (IBAction)backgroundClick:(id)sender {
    [self.view endEditing:YES];
    
}


-(void) cargarContactos:(NSString *) usuario {

    //Petición http
    NSHTTPURLResponse *response = nil;
    NSError *error;
    NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://localhost:8080/iGenda/webresources/servicios.contacto/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"GET enviado");
    NSArray *jsonArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:response1 options:0 error:&error];
    //Trabajamos con los datos JSON recibidos del servidor
    for (NSDictionary *dic in jsonArray){
        NSDictionary *contactos = [dic valueForKey:@"contactoPK"];
        NSString *usuarioDic = [contactos valueForKey:@"login"];
        if ([usuarioDic isEqualToString:usuario]){
            //Aquí se guardarán en core data los contactos correspondientes al usuario que ha hecho login
            [self crearUsuario:dic];
        }
    }
    //Por último, almacenamos también el usuario en el IGESetting de la aplicación
    [[(IGEAppDelegate*)[[UIApplication sharedApplication] delegate] settings] setUsuario:usuario];

    // Guardado del contexto
    [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];

}

-(void) crearUsuario: (NSDictionary *) dic{
    //Recuperación de datos
    NSArray* grupos = [self fetchGrupos];
    NSString *grupoContacto = [[dic valueForKey:@"grupo"] valueForKey:@"nombregrupo"];
    //Recupera contexto del Delegate
    _mno = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];     Contact *c = [NSEntityDescription insertNewObjectForEntityForName:@"IGEContact" inManagedObjectContext:_mno];
    c.nombre = [dic valueForKey:@"nombre"];
    c.apellido1 = [dic valueForKey:@"apellido1"];
    c.apellido2 = [dic valueForKey:@"apellido2"];
    c.email = [dic valueForKey:@"email"];
    c.telefono = [NSString stringWithFormat:@"%@", [dic valueForKey:@"telefono"]];
    c.estado = @2;
    c.favorito = [dic valueForKey:@"favorito"];
    for (IGEGroup* g in grupos){
        if ([g.nombre isEqualToString:grupoContacto]){
            c.newRelationship = g;
        }
    }
    if (c.newRelationship == nil && [grupoContacto length] != 0){
        //Su grupo no existe en el dispositivo, por tanto creamos uno nuevo y los enlazamos
        IGEGroup *g = [NSEntityDescription insertNewObjectForEntityForName:@"IGEGroup" inManagedObjectContext:_mno];
        g.nombre = grupoContacto;
        c.newRelationship = g;
    }
    
    
}
- (NSArray *) fetchGrupos {
    NSArray* grupos;
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGEGroup" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    grupos = [context executeFetchRequest:request error:&error];
    return grupos;
}

@end
