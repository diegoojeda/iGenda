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
    
    self.IP = [[NSMutableString alloc] initWithString:@"http://192.168.1.139"];
    self.inicioButton.enabled = NO;
    
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:YES];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}


- (IBAction) registerClick:(id)sender {
    
    
    
    
    if([[self.textUsername text] isEqualToString:@""]) {
        [self.activityIndicator setHidden:YES];
        [self alertStatus:@"Introduzca el nombre que desea y registrese": @"Usuario vacío" :0];
    }
    else{
        [self performSelectorInBackground:@selector(startActivity) withObject:nil];
        NSString *username = [self.textUsername text];
        NSString *usuario = [self fetchUser:username];
        NSLog(@"USUARIO FETCHED: %@", usuario);
        if (usuario == nil || [usuario length] == 0){
            //Registrar usuario
            NSLog(@"Registro nuevo usuario");
            [self crearUsuarioEnServidor:username];
            
            [self alertStatus:@"Su usuario ha sido registrado con éxito, ya puede Iniciar Sesión": @"Registrado con éxito" :0];
            [self.activityIndicator setHidden:YES];
        }
        else {
            [self.activityIndicator setHidden:YES];
            NSLog(@"El usuario ya existe");
            [self alertStatus:@"Este nombre de usuario ya está siendo utilizado. Pruebe con otro.": @"Usuario ya existente" :0];
        }
    }
}

- (void) startActivity
{
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
}

- (IBAction)loginClick:(id)sender
{
    NSInteger success = 0;
    
    
    if([[self.textUsername text] isEqualToString:@""]) {
        [self.activityIndicator setHidden:YES];
        [self alertStatus:@"Introduzca su nombre de usuario" :@"Usuario incorrecto" :0];
    }
    else {
        [self performSelectorInBackground:@selector(startActivity) withObject:nil];
        if([self fetchConnect] == 0){
            [self.activityIndicator setHidden:YES];
            NSLog(@"SIN CONEXIÓN");
            [self alertStatus:@"" :@"Sin conexión a la red" :0];
        }
        else{
            NSString *username = [self.textUsername text];
            NSString *str = [self fetchUser:[self.textUsername text]];
            
            if ([str length] > 0){
                //Conseguimos el número de versión
                
                NSLog(@"STR ES: %@",str);
                
                NSError *err = nil;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                NSLog(@"LOGIN SUCCESFUL %f",[[dic objectForKey:@"version"] floatValue]);
                //En el NSString str está almacenado el JSON, es genial =)
                [self cargarContactos:username conVersion: [dic objectForKey:@"version"]];
                success = 1;
                
            }
            else {
                [self.activityIndicator setHidden:YES];
                NSLog(@"FAIL");
                [self alertStatus:@"Vuelva a introducir su nombre correctamente" :@"Usuario incorrecto" :0];
            }
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
    NSMutableString *url = [[NSMutableString alloc] initWithString:self.IP];
    [url appendString:@":8080/igenda-777/webresources/igenda.contacto/"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"GET all contacts enviado");
    if (response1 == nil){
        [self alertStatus:@"Hubo un error durante el proceso de autenticación": @"Login fallido" :0];
    }
    else{
        NSManagedObjectContext *context = [(IGEAppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
        IGEGroup *grupo = [NSEntityDescription insertNewObjectForEntityForName:@"IGEGroup" inManagedObjectContext:context];
        grupo.nombre = @"<sin grupo>";
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
    NSString *grupoContacto = [dic valueForKey:@"grupo"];
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
    c.id = [dic valueForKey:@"idagenda"];
    c.imagen = nil;
    //Comprobamos si ya hemos creado el grupo al que pertenece este contacto
    for (IGEGroup* g in gruposEnDispositivo){
        if ([g.nombre isEqualToString:grupoContacto]){
            //IGEGroup *group = [NSEntityDescription insertNewObjectForEntityForName:@"IGEGroup" inManagedObjectContext:_mno];
            //c.newRelationship = g;
            [g addContactosObject:c];
        }
    }
    if (c.grupo == nil){
        //Su grupo no existe en el dispositivo, por tanto creamos uno nuevo y los enlazamos
        IGEGroup *grupo = [NSEntityDescription insertNewObjectForEntityForName:@"IGEGroup" inManagedObjectContext:_mno];
        grupo.nombre = grupoContacto;
        [grupo addContactosObject:c];
        //c.newRelationship = grupo;
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



- (void) crearUsuarioEnServidor: (NSString *) username {
    //Creamos diccionario con la información del usuario
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:1];
    [dic setObject:username forKey:@"login"];
    [dic setObject:@0 forKey:@"version"];
    //Convertimos el diccionario a JSON y luego a NSData
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error]; // Pass 0 if you don't care about the readability of the generateds string
    NSLog(@"JSONDATA: %@", [NSString stringWithUTF8String:[jsonData bytes]]);
    //Creamos y ejecutamos la petición
    
    NSMutableString *urlaux = [[NSMutableString alloc] initWithString:self.IP];
    [urlaux appendString:@":8080/igenda-777/webresources/igenda.usuario/"];
    
    NSURL *url = [[NSURL alloc] initWithString:urlaux];
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



/**** LOGIN ****/
/**
 Consulta si un usuario existe en la base de datos
 **/
- (NSString *) fetchUser :(NSString *) userName {
    NSHTTPURLResponse  *response = nil;
    NSError *error;
    NSString* username = [[NSString alloc]initWithString:[self.textUsername text]];
    NSMutableString *url = [[NSMutableString alloc] initWithString:self.IP];
    [url appendString:@":8080/igenda-777/webresources/igenda.usuario/"];
    [url appendString:username];
    
    NSLog(@"URL ENVIADA %@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"GET usuario en login enviado");
    NSString *str = [[NSString alloc]initWithData:response1 encoding:NSUTF8StringEncoding];
    
    return str;
}

/**
 Prueba la conexión
 **/
- (int) fetchConnect {
    NSHTTPURLResponse  *response = nil;
    NSError *error;
    NSMutableString *url = [[NSMutableString alloc] initWithString:self.IP];
    [url appendString:@":8080/igenda-777/webresources/igenda.usuario"];//Cambiar a un usuario de prueba sin contactos
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:1000];
    [request setHTTPMethod: @"GET"];
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    
    if(response1 == nil)
        return 0;
    else
        return 1;
    
}





/**** VALIDACIÓN ****/
/**
 Si no hay usuario, se inhabilita el botón
 */
- (IBAction)changeUsuario:(id)sender{
    
    if(self.textUsername.text.length > 0)
        self.inicioButton.enabled = YES;
    else
        self.inicioButton.enabled = NO;
}



@end
















