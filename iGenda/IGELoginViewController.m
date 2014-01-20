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


- (IBAction) registerClick:(id)sender {
    if([[self.textUsername text] isEqualToString:@""] || [[self.textPassword text] isEqualToString:@""] ) {
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
        }
        else {
            NSLog(@"El usuario ya existia");
            [self alertStatus:@"Ese nombre de usuario ya está siendo utilizado": @"Registro fallido" :0];
        }
    }
}


- (IBAction)loginClick:(id)sender
{
    NSInteger success = 0;
    if([[self.textUsername text] isEqualToString:@""] || [[self.textPassword text] isEqualToString:@""] ) {
        [self alertStatus:@"Introduzca su nombre de usuario" :@"Login fallido" :0];
    }
    else {
        NSString *username = [self.textUsername text];
        NSString *str = [self fetchUser:[self.textUsername text]];
        if ([str length] > 0){
            //Conseguimos el número de versión
            NSError *err = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            // access the dictionaries
            //NSMutableDictionary *dict = arr[0];
            NSLog(@"LOGIN SUCCESFUL");
            //En el NSString str está almacenado el JSON, es genial =)
            [self cargarContactos:username conVersion: [dic objectForKey:@"version"]];
            success = 1;
        }
        else {
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

    //Petición http
    NSLog(@"Recibo version: %@", ver);
    NSHTTPURLResponse *response = nil;
    NSError *error;
    NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://localhost:8080/igenda/webresources/webservices.contacto/"];
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
    
    /*NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGESetting" inManagedObjectContext:context];
    NSFetchRequest *requestCoreData = [[NSFetchRequest alloc] init];
    [requestCoreData setEntity:entityDescription];
    [(IGESetting *)[[context executeFetchRequest:requestCoreData error:&error] firstObject] setUsuario:usuario];
    //IGESetting *set =[[context executeFetchRequest:requestCoreData error:&error] firstObject];
    //set.usuario = usuario;
    */
    NSManagedObjectContext *context = [(IGEAppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    IGESetting * set = [NSEntityDescription insertNewObjectForEntityForName:@"IGESetting" inManagedObjectContext:context];
    set.usuario = usuario;
    set.versionAgenda = ver;
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

- (NSString *) fetchUser :(NSString *) userName {
    NSHTTPURLResponse  *response = nil;
    NSError *error;
    NSString* username = [[NSString alloc]initWithString:[self.textUsername text]];
    NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://localhost:8080/igenda/webresources/webservices.usuario/"];
    [url appendString:username];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"GET enviado");
    NSString *str = [[NSString alloc]initWithData:response1 encoding:NSUTF8StringEncoding];
    NSLog(@"SERA AQUI? %@", str);
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
    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/igenda/webresources/webservices.usuario"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:jsonData];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    NSURLResponse *response = nil;
    NSLog(@"Justo antes de lanzar la petición al servidor");
    NSData *responsedata = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    NSLog(@"Petición terminada");
    NSString *data=[[NSString alloc]initWithData:responsedata encoding:NSUTF8StringEncoding];
    NSLog(@"Respuesta: %@", data);
}

@end