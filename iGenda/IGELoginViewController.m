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
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:YES];
    //[self.activityIndicator a]
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


- (IBAction) registerClick:(id)sender {
    if([[self.textUsername text] isEqualToString:@""]) {
        [self alertStatus:@"Introduzca el nombre que desea y luego pulse registrar": @"Registro fallido" :0];
    }
    else{
        NSString *username = [self.textUsername text];
        NSString *usuario = [self fetchUser:username];
        NSLog(@"USUARIO FETCHED: %@", usuario);
        if (usuario == nil || [usuario length] == 0){
            //Registrar usuario
            NSLog(@"Registro nuevo usuario");
            [self crearUsuarioEnServidor:username];
            
            [self alertStatus:@"Usuario registrado con éxito": @"Registro exitoso" :0];
        }
        else {
            [self.activityIndicator setHidden:YES];
            NSLog(@"El usuario ya existia");
            [self alertStatus:@"Ese nombre de usuario ya está siendo utilizado": @"Registro fallido" :0];
        }
    }
}

- (void) startActivity
{
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    //[self.activityIndicator setHidden:YES];
}
- (void) stopActivity
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
}

- (IBAction)loginClick:(id)sender
{
    NSInteger success = 0;
    if([[self.textUsername text] isEqualToString:@""]) {
        [self alertStatus:@"Introduzca su nombre de usuario" :@"Login fallido" :0];
    }
    else {
        NSString *username = [self.textUsername text];
        NSString *str = [self fetchUser:[self.textUsername text]];
        if ([str length] > 0){
            NSLog(@"LOGIN: %@", str);
            //Conseguimos el número de versión
            NSError *err = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            NSLog(@"LOGIN SUCCESFUL");
            //En el NSString str está almacenado el JSON, es genial =)
            [self cargarContactos:username conVersion: [dic objectForKey:@"version"]];
            success = 1;
            
        }
        else {
            [self.activityIndicator setHidden:YES];
            NSLog(@"FAIL");
            [self alertStatus:@"Nombre de usuario incorrecto" :@"Login fallido" :0];
        }
    }
    if (success) {
        [self performSegueWithIdentifier:@"login_success" sender:self];
    }
}

- (IBAction)backgroundClick:(id)sender {
    [self.view endEditing:YES];
    
}


-(void) cargarContactos:(NSString *) usuario conVersion: (NSNumber *) ver{

    //Petición http para recuperar todos los contactos
    NSLog(@"Recibo version: %@", ver);
    NSHTTPURLResponse *response = nil;
    NSError *error;
    NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://localhost:8080/igenda-rs/webresources/igenda.contacto/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"GET all contacts enviado");
    if (response1 == nil){
        [self alertStatus:@"Hubo un error durante el proceso de autenticación": @"Login fallido" :0];
    }
    else{
        NSArray *jsonArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:response1 options:0 error:&error];
        int contadorContactos = 0;
        //Trabajamos con los datos JSON recibidos del servidor
        for (NSDictionary *dic in jsonArray){
            NSDictionary *contactos = [dic valueForKey:@"login"];
            NSString *usuarioDic = [contactos valueForKey:@"login"];
            if ([usuarioDic isEqualToString:usuario]){
                //Aquí se guardarán en core data los contactos correspondientes al usuario que ha hecho login
                [self leerContacto:dic];
                contadorContactos++;
            }
        }
        //NSLog(@"JSON ARRAY COUNT: %lu", [jsonArray count]);
        //Por último, almacenamos también el usuario en el IGESetting de la aplicación
        //[(IGEAppDelegate *) [[UIApplication sharedApplication] delegate] setSeqId:[NSNumber numberWithUnsignedInteger:[jsonArray count]]];
        NSManagedObjectContext *context = [(IGEAppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
        IGESetting * set = [NSEntityDescription insertNewObjectForEntityForName:@"IGESetting" inManagedObjectContext:context];
        [set setValue:usuario forKey:@"usuario"];
        [set setValue:ver forKey:@"versionAgenda"];
        [set setValue:[NSNumber numberWithInt:contadorContactos++] forKey:@"numSeq"];
        //set.usuario = usuario;
        //set.versionAgenda = ver;
        //set.numSeq = [ NSNumber numberWithInt:contadorContactos++];
        // Guardado del contexto
        [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    }
}

-(void) leerContacto: (NSDictionary *) dic{
    //Recuperación de datos
    //Recuperamos los grupos que teníamos almacenados actualmente en el gestor de persistencia (core data)
    NSArray* gruposEnDispositivo = [self fetchGrupos];
    NSDictionary *grupoContacto = [dic valueForKey:@"grupo"];
    //Recupera contexto del Delegate
    _mno = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    Contact *c = [NSEntityDescription insertNewObjectForEntityForName:@"IGEContact" inManagedObjectContext:_mno];
    c.nombre = [dic valueForKey:@"nombre"];
    c.apellido1 = [dic valueForKey:@"apellido1"];
    c.apellido2 = [dic valueForKey:@"apellido2"];
    c.email = [dic valueForKey:@"email"];
    c.telefono = [NSString stringWithFormat:@"%@", [dic valueForKey:@"telefono"]];
    c.estado = @2;
    c.favorito = [dic valueForKey:@"favorito"];
    c.id = [dic valueForKey:@"idAgenda"];
    //Comprobamos si ya hemos creado el grupo al que pertenece este contacto
    for (IGEGroup* g in gruposEnDispositivo){
        if ([g.nombre isEqualToString:[grupoContacto valueForKey:@"nombregrupo"]]){
            c.newRelationship = g;
            [g addNewRelationshipObject:c];
        }
    }
    if (c.newRelationship == nil && [grupoContacto valueForKey:@"nombregrupo"] != 0){
        //Su grupo no existe en el dispositivo, por tanto creamos uno nuevo y los enlazamos
        IGEGroup *grupo = [NSEntityDescription insertNewObjectForEntityForName:@"IGEGroup" inManagedObjectContext:_mno];
        grupo.nombre = [grupoContacto valueForKey:@"nombregrupo"];
        [grupo addNewRelationshipObject:c];
        c.newRelationship = grupo;
    }
}

//Devuelve los IEGroup almacenados en el gestor de persistencia
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

- (NSString *) fetchUser :(NSString *) userName {
    NSHTTPURLResponse  *response = nil;
    NSError *error;
    NSString* username = [[NSString alloc]initWithString:[self.textUsername text]];
    NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://localhost:8080/igenda-rs/webresources/igenda.usuario/"];
    [url appendString:username];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"GET usuario en login enviado");
    NSString *str = [[NSString alloc]initWithData:response1 encoding:NSUTF8StringEncoding];
    return str;
}

- (void) crearUsuarioEnServidor: (NSString *) username {
    //Creamos diccionario con la información del usuario
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:1];
    [dic setObject:username forKey:@"login"];
    [dic setObject:@0 forKey:@"version"];
    //Convertimos el diccionario a JSON y luego a NSData
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error]; // Pass 0 if you don't care about the readability of the generateds string
    
    //Creamos y ejecutamos la petición
    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/igenda-rs/webresources/igenda.usuario"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:jsonData];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    NSURLResponse *response = nil;
    NSLog(@"Justo antes de lanzar la petición al servidor");
    NSData *responsedata = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    NSLog(@"Petición terminada");
    NSString *data=[[NSString alloc]initWithData:responsedata encoding:NSUTF8StringEncoding];
    NSLog(@"Respuesta: %@", data);
}

@end