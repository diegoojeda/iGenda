//
//  IGESettingsViewController.m
//  iGenda
//
//  Created by Diego Ojeda García on 18/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGESettingsViewController.h"

@interface IGESettingsViewController ()
- (IBAction)deleteLoginData:(id)sender;
- (IBAction)actualizarAgenda:(id)sender;
- (IBAction)exportarAgenda:(id)sender;
@end

@implementation IGESettingsViewController

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

- (IBAction)deleteLoginData:(id)sender {
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    
    // retrieve the store URL
    NSURL * storeURL = [[context persistentStoreCoordinator] URLForPersistentStore:[[[context persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [context lock];
    [context reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[context persistentStoreCoordinator] removePersistentStore:[[[context persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [[context persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [context unlock];
    //that's it !
}

- (IBAction)actualizarAgenda:(id)sender{
    //Cogemos la versión del dispositivo
    [self sincronizar];
    
}

- (IBAction)exportarAgenda:(id)sender{
    
}

- (void) sincronizar {
    NSNumber *versionServidor = [[NSNumber alloc] init];
    NSNumber *versionDispositivo = [[NSNumber alloc] init];
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGESetting" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSArray *s = [context executeFetchRequest:request error:&error];
    NSString *userName = [[s firstObject] usuario];
    versionDispositivo = [[s firstObject] versionAgenda];
    NSLog(@"USERNAME: %@", userName);
    NSLog(@"VERSION AGENDA: %@", versionDispositivo);
    //Preparamos la petición al servidor
    NSHTTPURLResponse *response = nil;
    NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://192.168.1.139:8080/igenda/webresources/webservices.usuario/"];
    [url appendString:userName];
    NSMutableURLRequest *URLrequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [URLrequest setHTTPMethod: @"GET"];
    NSData *response1 = [NSURLConnection sendSynchronousRequest:URLrequest returningResponse:&response error:&error];
    NSDictionary * parsedData = [NSJSONSerialization JSONObjectWithData:response1 options:0 error:&error];
    versionServidor = [parsedData objectForKey:@"version"];
    NSLog(@"Procedo a actualizar el servidor");
    [self actualizarServidorconUsuario:userName];
    //Si versionDispositivo > versionServidor procedemos con la sincronización. Almacenamos los datos del dispositivo en el servidor
    if (versionDispositivo > versionServidor){
        //[self actualizarServidorconUsuario:userName];
    }
    
    //Si versionDispositivo < versionServidor requerimos al usuario que importe los contactos
    
    //Si versionDispositivo == versionServidor informamos de que no es necesario realizar ninguna acción.
}


- (void) actualizarServidorconUsuario: (NSString *) userName{
    NSMutableArray *arrayCreados = [[NSMutableArray alloc] init];
    NSMutableArray *arrayEditados = [[NSMutableArray alloc] init];
    //Recuperamos todos los contactos y vemos cuales han sido creados y cuales editados para hacer la actualización más eficiente. Más tarde procederemos con los borrados.
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGEContact" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSArray *s = [context executeFetchRequest:request error:&error];
    for (Contact *c in s){
        c.id = @2;
        [arrayCreados addObject:c]; //BORRAR ESTO DENTRO DE UN RATO
        if ([c.estado  isEqual: @0]){
            //Contacto creado, añadimos a arrayCreados
            [arrayCreados addObject:c];
        }
        else if ([c.estado  isEqual: @1]){
            //Contacto editado, añadimos a arrayEditados
            [arrayEditados addObject:c];
        }
    }
    
    //Procedemos con los marcados para borrar.
    entityDescription = [NSEntityDescription entityForName:@"IGEContactToDelete" inManagedObjectContext:context];
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSArray *marcadosBorrar = [context executeFetchRequest:request error:&error];
    
    
    //Realizamos las actualizaciones procedentes en el servidor
    if ([arrayCreados count] != 0){
        NSLog(@"Detectado al menos un contacto creado");
        [self crearContactosEnServidor:arrayCreados conUsuario:userName];
    }
    if ([arrayEditados count] != 0){
        //[self editarContactosEnServidor:arrayEditados];
    }
    if ([marcadosBorrar count] != 0){
        //[self eliminarContactosEnServidor:marcadosBorrar];
    }
    //Por último, procedemos a marcar todos los contactos con un estado = 2 (actualizados) y a borrar los marcados para borrar del almacenamiento persistente.
    //[self actualizarInformacionPersistente];
    //También procedemos a actualizar correctamente el número de versión
    
    
}

- (void) crearContactosEnServidor: (NSMutableArray *) contactos conUsuario: (NSString *) usuario{
    NSMutableArray *arrayDiccionarios = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic;
    NSError *errorJSON = nil;
    for (Contact *c in contactos){
        //No se puede hacer una conversión directa del array a JSON, ya que hay campos que no almacenamos en el servidor (imagen y estado :((( )
        dic = [[NSMutableDictionary alloc] init];
        [dic setObject:c.id forKey:@"id"];
        [dic setObject:c.nombre forKey:@"nombre"];
        [dic setObject:c.apellido1 forKey:@"apellido1"];
        [dic setObject:c.apellido2 forKey:@"apellido2"];
        [dic setObject:c.telefono forKey:@"telefono"];
        [dic setObject:c.email forKey:@"email"];
        [dic setObject:usuario forKey:@"login"];
        [dic setObject:c.favorito forKey:@"favorito"];
        [dic setObject:c.newRelationship.nombre forKey:@"grupo"];
        [arrayDiccionarios addObject:dic];
    }
    //Una vez tenemos creado un array de diccionarios en el que cada diccionario es un contacto, procedemos a transformarlo a JSON y a mandarlo al servidor por HTTP POST
    NSLog(@"COMPROBANDO JSON");
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayDiccionarios options:0 error:&errorJSON];
    NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSLog(@"JSON OUTPUT: %@",JSONString);
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.139:8080/igenda/webresources/webservices.contacto"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    NSURLResponse *respuesta;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&respuesta error:&errorJSON];
    NSLog(@"INFORMACION ENVIADA AL SERVIDOR. RESPUESTA: %@", respuesta);
}

- (void) editarContactosEnServidor: (NSMutableArray *) contactos{
    
}

- (void) eliminarContactosEnServidor: (NSArray *) contactos{
    
}
- (void) actualizarInformacionPersistente {
    
}

/*
 
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

 
 
 
 
 */







@end
