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

@synthesize versDispositivo = _versDispositivo;
@synthesize nomUsuario = _nomUsuario;
@synthesize context = _context;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGESetting" inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSArray *s = [_context executeFetchRequest:request error:&error];
    _nomUsuario = [[s firstObject] usuario];
    _versDispositivo = [[s firstObject] versionAgenda];
    self.IP = [[NSMutableString alloc] initWithString:@"http://192.168.1.139:8080"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIAlertView *) alertStatusWithButton:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
    return alertView;
}

- (UIAlertView *) alertStatusWithoutButton:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
    return alertView;
}

- (IBAction)deleteLoginData:(id)sender {
    //Borramos todos los datos del almacenamiento persistente de la aplicación.
    NSLog(@"LOGGING OUT");
    NSError *error = nil;
    // retrieve the store URL
    NSURL * storeURL = [[_context persistentStoreCoordinator] URLForPersistentStore:[[[_context persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [_context lock];
    [_context reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[_context persistentStoreCoordinator] removePersistentStore:[[[_context persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [[_context persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [_context unlock];
    //that's it !
}


- (IBAction)actualizarAgenda:(id)sender{
    [self sincronizar];
}

- (IBAction)exportarAgenda:(id)sender{
    NSLog(@"Llego aqui");
    UIAlertView *alerta = [self alertStatusWithoutButton:@"Restaurando copia de seguridad. Espere..." :@"Restaurando" :0];
    NSArray *contactosDispositivo = [self fetchEntitesArray:@"IGEContact"];
    for (Contact *c in contactosDispositivo){
        [_context deleteObject:c];
    }
    for (IGEGroup *g in [self fetchGrupos]){
        [_context deleteObject:g];
    }
    for (Contact *c in [self fetchEntitesArray:@"IGEContactToDelete"]){
        [_context deleteObject:c];
    }
    [self cargarContactos:_nomUsuario];
    [self actualizarVersionDispositivo];
    NSLog(@"Procedemos a actualizar la información persistente (el estado de los contactos)");
    [self actualizarInformacionPersistente];
    NSLog(@"Información persistente actualizada");
    [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    [alerta dismissWithClickedButtonIndex:0 animated:YES];
    [self alertStatusWithButton:@"Copia de seguridad restaurada con éxito" :@"Restaurar copia de seguridad" :0];
}

- (void) sincronizar {
    UIAlertView *alerta;
    NSNumber *versionServidor = [[NSNumber alloc] init];
    NSError *error;
    //NSLog(@"USERNAME: %@", _nomUsuario);
    //NSLog(@"VERSION AGENDA: %@", _versDispositivo);
    //Preparamos la petición al servidor
    NSHTTPURLResponse *response = nil;
    NSMutableString *url = [[NSMutableString alloc] initWithFormat:@"%@%@" ,self.IP, @"/igenda-777/webresources/igenda.usuario/"];
    [url appendFormat:@"%@",_nomUsuario];
    NSLog(@"URL: %@", url);
    NSMutableURLRequest *URLrequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [URLrequest setHTTPMethod: @"GET"];
    NSData *response1 = [NSURLConnection sendSynchronousRequest:URLrequest returningResponse:&response error:&error];
    if (response1 == nil){
        [self errorDeRed];
    }
    else{
        NSDictionary * parsedData = [NSJSONSerialization JSONObjectWithData:response1 options:0 error:&error];
        versionServidor = [parsedData objectForKey:@"version"];
        NSLog(@"Procedo a actualizar el servidor");
        NSLog(@"VERSDISPOSITIVO: %@ VERSSERVIDOR: %@", _versDispositivo, versionServidor);
        //Si versionDispositivo > versionServidor procedemos con la sincronización. Almacenamos los datos del dispositivo en el servidor
        if ([_versDispositivo intValue] > [versionServidor intValue]){
            alerta = [self alertStatusWithoutButton:@"Actualización del servidor en curso..." :@"Actualizando" :0];
            [self actualizarServidor];
            [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] setModified:false];
            [alerta dismissWithClickedButtonIndex:0 animated:NO];
            [self alertStatusWithButton:@"La actualización se ha realizado con éxito" :@"Dispositivo actualizado" :0];
        }
        
        //Si versionDispositivo == versionServidor informamos de que no es necesario realizar ninguna acción
        else if ([_versDispositivo intValue] == [versionServidor intValue]){
            [self alertStatusWithButton:@"El dispositivo ya está actualizado" :@"No es necesario actualizar" :0];
            NSLog(@"Dispositivo actualizado");
        }
        //Si versionDispositivo < versionServidor requerimos al usuario que importe los contactos
        else{
            NSLog(@"Dispositivo no actualizado");
            alerta = [self alertStatusWithoutButton:@"Actualización del dispositivo en curso..." :@"Actualizando" :0];
            //[self alertStatus:@"La actualización se ha realizado con éxito" :@"Necesario actualizar" :0];
            [self actualizarDispositivoYLuegoServidor];
            [alerta dismissWithClickedButtonIndex:0 animated:NO];
            [self alertStatusWithButton:@"La actualización se ha realizado con éxito" :@"Dispositivo actualizado" :0];
        }
    }
}


- (void) actualizarServidor{
    NSMutableArray *arrayCreados = [[NSMutableArray alloc] init];
    NSMutableArray *arrayEditados = [[NSMutableArray alloc] init];
    //Recuperamos todos los contactos y vemos cuales han sido creados y cuales editados para hacer la actualización más eficiente. Más tarde procederemos con los borrados.
    NSArray *s = [self fetchEntitesArray:@"IGEContact"];
    NSLog(@"DIME QUE FUNCIONA: %lu", (unsigned long)[s count]);
    for (Contact *c in s){
        if ([c.estado  isEqual: @0]){
            //Contacto creado, añadimos a arrayCreados
            NSLog(@"Añado contacto a creados");
            [arrayCreados addObject:c];
        }
        else if ([c.estado  isEqual: @1]){
            //Contacto editado, añadimos a arrayEditados
            NSLog(@"añado contacto a editados");
            [arrayEditados addObject:c];
        }
    }
    
    //Procedemos con los marcados para borrar.
    NSArray *marcadosBorrar = [self fetchEntitesArray:@"IGEContactToDelete"];
    
    //Realizamos las actualizaciones procedentes en el servidor
    if ([arrayCreados count] != 0){
        NSLog(@"Detecto %lu contactos creados, " ,(unsigned long)[arrayCreados count]);
        [self crearContactosEnServidor:arrayCreados];
    }
    if ([arrayEditados count] != 0){
        NSLog(@"Detecto %lu contactos editados, " ,(unsigned long)[arrayEditados count]);
        [self editarContactosEnServidor:arrayEditados];
    }
    if ([marcadosBorrar count] != 0){
         NSLog(@"Detecto %lu contactos borrados, " ,(unsigned long)[marcadosBorrar count]);
        [self eliminarContactosEnServidor:marcadosBorrar];
    }
    //Actualizamos la versión en el servidor
    [self actualizarVersion];
    //Por último, procedemos a marcar todos los contactos con un estado = 2 (actualizados) y a borrar los marcados para borrar del almacenamiento persistente.
    NSLog(@"Procedemos a actualizar la información persistente");
    [self actualizarInformacionPersistente];
    NSLog(@"Información persistente actualizada");
    //También procedemos a actualizar correctamente el número de versión en el servidor
    //[self alertStatus:@"Contactos actualizados con éxito" :@"Éxito" :0];
    
}

- (void) crearContactosEnServidor: (NSMutableArray *) contactos{
    NSMutableDictionary *dic, *dicLogin;
    NSError *errorJSON = nil;
    //NSNumber *numVersion =
    for (Contact *c in contactos){
        NSString *strID = [[NSString alloc] initWithFormat:@"%@+%@", c.id, _nomUsuario];
        //No se puede hacer una conversión directa del array a JSON, ya que hay campos que no almacenamos en el servidor (imagen y estado :((( )
        dic = [[NSMutableDictionary alloc] init];
        dicLogin = [[NSMutableDictionary alloc] init];
        [dicLogin setObject:_nomUsuario forKey:@"login"];
        [dicLogin setObject:_versDispositivo forKey:@"version"];
        [dic setObject:c.apellido1 forKey:@"apellido1"];
        [dic setObject:c.apellido2 forKey:@"apellido2"];
        [dic setObject:c.email forKey:@"email"];
        [dic setObject:c.favorito forKey:@"favorito"];
        [dic setObject:c.grupo.nombre forKey:@"grupo"];
        [dic setObject:c.nombre forKey:@"nombre"];
        [dic setObject:c.telefono forKey:@"telefono"];
        [dic setObject:dicLogin forKey:@"login"];
        [dic setObject:strID forKey:@"idbd"];
        [dic setObject:c.id forKey:@"idagenda"];
        NSLog(@"COMPROBANDO JSON");
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&errorJSON];
        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        NSLog(@"JSON OUTPUT: %@",JSONString);
        NSString *url = [[NSMutableString alloc] initWithFormat:@"%@%@" ,self.IP, @"/igenda-777/webresources/igenda.contacto"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        NSHTTPURLResponse *respuesta;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&respuesta error:&errorJSON];
        NSLog(@"INFORMACION ENVIADA AL SERVIDOR. RESPUESTA: %@", respuesta);
        if ([respuesta statusCode] > 200 && [respuesta statusCode] <300){
            NSLog(@"Todo correcto. Contacto creado en el servidor");
        }
        else{
            NSLog(@"Error al crear un contacto en el servidor.");
        }
    }

}

- (void) editarContactosEnServidor: (NSMutableArray *) contactos{
    NSMutableDictionary *dic, *dicLogin;
    NSError *errorJSON = nil;
    for (Contact *c in contactos){
        NSString *strID = [[NSString alloc] initWithFormat:@"%@+%@", c.id, _nomUsuario];
        //No se puede hacer una conversión directa del array a JSON, ya que hay campos que no almacenamos en el servidor (imagen y estado :((( )
        dic = [[NSMutableDictionary alloc] init];
        dicLogin = [[NSMutableDictionary alloc] init];
        [dicLogin setObject:_nomUsuario forKey:@"login"];
        [dicLogin setObject:@0 forKey:@"version"];
        [dic setObject:c.apellido1 forKey:@"apellido1"];
        [dic setObject:c.apellido2 forKey:@"apellido2"];
        [dic setObject:c.email forKey:@"email"];
        [dic setObject:c.favorito forKey:@"favorito"];
        [dic setObject:c.grupo.nombre forKey:@"grupo"];
        [dic setObject:c.nombre forKey:@"nombre"];
        [dic setObject:c.telefono forKey:@"telefono"];
        [dic setObject:dicLogin forKey:@"login"];
        [dic setObject:strID forKey:@"idbd"];
        [dic setObject:c.id forKey:@"idagenda"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&errorJSON];
        //NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        //NSLog(@"JSON OUTPUT: %@",JSONString);
        NSMutableString *urlStr = [[NSMutableString alloc] initWithFormat:@"%@%@" ,self.IP, @"/igenda-777/webresources/igenda.contacto/edit/"];
        [urlStr appendString:strID];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        NSHTTPURLResponse *respuesta;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&respuesta error:&errorJSON];
        NSLog(@"INFORMACION ENVIADA AL SERVIDOR PARA EDITAR. RESPUESTA: %@", respuesta);
        if ([respuesta statusCode] > 200 && [respuesta statusCode] <300){
            NSLog(@"Todo correcto. Contacto editado en el servidor");
        }
        else{
            NSLog(@"Error al editar un contacto en el servidor.");
        }
    }
}

- (void) eliminarContactosEnServidor: (NSArray *) contactos{
    //NSMutableDictionary *dicLogin, *dic;
    NSError *errorJSON = nil;
    for (Contact *c in contactos){
        NSString *strID = [[NSString alloc] initWithFormat:@"%@+%@", c.id, _nomUsuario];
        NSMutableString *urlStr = [[NSMutableString alloc] initWithFormat:@"%@%@" ,self.IP, @"/igenda-777/webresources/igenda.contacto/delete/"];
        [urlStr appendString:strID];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"GET"];
        NSHTTPURLResponse *respuesta;
        //NSLog(@"JSON STRING: %@", JSONString);
        [NSURLConnection sendSynchronousRequest:request returningResponse:&respuesta error:&errorJSON];
        NSLog(@"INFORMACION ENVIADA AL SERVIDOR PARA ELIMINAR. RESPUESTA: %@", respuesta);
        //NSLog(@"Respuesta delete: %@", respuesta);
        if ([respuesta statusCode] > 200 && [respuesta statusCode] <300){
            NSLog(@"Todo correcto. Contacto eliminado en el servidor");
        }
        else{
            NSLog(@"Error al eliminar un contacto en el servidor.");
        }
        [_context deleteObject:c];
    }
}



- (void) actualizarInformacionPersistente{
    //Fetch contacts en core data y cambiar su estado
    NSArray *s = [self fetchEntitesArray:@"IGEContact"];
    for (Contact *c in s){
        [c setPrimitiveValue:@2 forKey:@"estado"];
    }
    [(IGEAppDelegate *) [[UIApplication sharedApplication] delegate] saveContext];
}

- (void) actualizarVersion {
    NSMutableDictionary *dicLogin = [[NSMutableDictionary alloc]init];
    NSError *errorJSON = nil;
    IGESetting *set = [[self fetchEntitesArray:@"IGESetting"] firstObject];
    [dicLogin setObject:_nomUsuario forKey:@"login"];
    [dicLogin setObject:set.versionAgenda forKey:@"version"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicLogin options:0 error:&errorJSON];
    //NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    //NSLog(@"JSON OUTPUT: %@",JSONString);
    NSMutableString *urlStr = [[NSMutableString alloc] initWithFormat:@"%@%@", self.IP, @"/igenda-777/webresources/igenda.usuario/edit/"];
    [urlStr appendString:_nomUsuario];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    NSHTTPURLResponse *respuesta;
    //NSLog(@"JSON STRING ACTUALIZAR VERSION: %@", JSONString);
    [NSURLConnection sendSynchronousRequest:request returningResponse:&respuesta error:&errorJSON];
    //NSLog(@"INFORMACION ENVIADA AL SERVIDOR PARA ACTUALIZAR LA VERSION. RESPUESTA: %@", respuesta);
    if ([respuesta statusCode] > 200 && [respuesta statusCode] <300){
        NSLog(@"Todo correcto. VERSION Actualizada");
    }
    else{
        NSLog(@"Error al actualizar la version en el servidor.");
    }

}

- (void) actualizarDispositivoYLuegoServidor {
    NSMutableArray *arrayCreados = [[NSMutableArray alloc] init];
    NSMutableArray *arrayEditados = [[NSMutableArray alloc] init];
    //Recuperamos todos los contactos y vemos cuales han sido creados y cuales editados para hacer la actualización más eficiente. Más tarde procederemos con los borrados.
    NSArray *s = [self fetchEntitesArray:@"IGEContact"];
    for (Contact *c in s){
        if ([c.estado  isEqual: @0]){
            //Contacto creado, añadimos a arrayCreados
            [arrayCreados addObject:c];
        }
        else if ([c.estado  isEqual: @1]){
            //Contacto editado, añadimos a arrayEditados
            NSLog(@"añado contacto a editados");
            [arrayEditados addObject:c];
        }
    }
    //Procedemos con los marcados para borrar.

    NSArray *marcadosBorrar = [self fetchEntitesArray:@"IGEContactToDelete"];
    if ([arrayCreados count] != 0){
        NSLog(@"Detectado al menos un contacto creado");
        [self crearContactosEnServidor:arrayCreados];
    }
    if ([arrayEditados count] != 0){
        [self editarContactosEnServidor:arrayEditados];
    }
    if ([marcadosBorrar count] != 0){
        [self eliminarContactosEnServidor:marcadosBorrar];
    }
    //Una vez tenemos almacenados todos los datos que vamos a modificar en el servidor, procedemos a descargar la última versión de éste.
    //Antes que nada borramos los usuarios y grupos que hay en este momento en la aplicación
    for (Contact *c in [self fetchEntitesArray:@"IGEContact"]){
        [_context deleteObject:c];
    }
    for (IGEGroup *g in [self fetchGrupos]){
        [_context deleteObject:g];
    }
    //Una vez borrados todos los contactos y grupos en el dispositivo procedemos a descargar la última versión del servidor.
    [self cargarContactos:_nomUsuario];

    //Actualizamos la versión en el dispositivo
    [self actualizarVersionDispositivo];
    //Por último, procedemos a marcar todos los contactos con un estado = 2 (actualizados) y a borrar los marcados para borrar del almacenamiento persistente.
    NSLog(@"Procedemos a actualizar la información persistente");
    [self actualizarInformacionPersistente];
    NSLog(@"Información persistente actualizada");
    //También procedemos a actualizar correctamente el número de versión en el servidor

}


-(void) cargarContactos:(NSString *) usuario{
    
    //Petición http para recuperar todos los contactos
    //NSLog(@"Recibo version: %@", ver);
    NSHTTPURLResponse *response = nil;
    NSError *error;
    NSMutableString *url = [[NSMutableString alloc] initWithString:self.IP];
    [url appendString:@"/igenda-777/webresources/igenda.contacto/"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //NSLog(@"GET all contacts enviado");
    IGEGroup *grupo = [NSEntityDescription insertNewObjectForEntityForName:@"IGEGroup" inManagedObjectContext:_context];
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
    [(IGEAppDelegate *)[[UIApplication sharedApplication]delegate]setSeqId:[NSNumber numberWithInt:contadorContactos]];
    //Por último, almacenamos también el usuario en el IGESetting de la aplicación
    [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

-(void) leerContacto: (NSDictionary *) dic{
    //Recuperación de datos
    //Recuperamos los grupos que teníamos almacenados actualmente en el gestor de persistencia (core data)
    NSArray* gruposEnDispositivo = [self fetchGrupos];
    NSString *grupoContacto = [dic valueForKey:@"grupo"];
    //Recupera contexto del Delegate
    Contact *c = [NSEntityDescription insertNewObjectForEntityForName:@"IGEContact" inManagedObjectContext:_context];
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
            [g addContactosObject:c];
        }
    }
    if (c.grupo == nil){
        //Su grupo no existe en el dispositivo, por tanto creamos uno nuevo y los enlazamos
        IGEGroup *grupo = [NSEntityDescription insertNewObjectForEntityForName:@"IGEGroup" inManagedObjectContext:_context];
        grupo.nombre = grupoContacto;
        [grupo addContactosObject:c];
    }
}

//Devuelve los IEGroup almacenados en el gestor de persistencia
- (NSArray *) fetchGrupos {
    return [self fetchEntitesArray:@"IGEGroup"];
}

-(void) actualizarVersionDispositivo {
    NSHTTPURLResponse  *response = nil;
    NSError *error;
    //NSString* username = [[NSString alloc]initWithString:[self.textUsername text]];
    NSMutableString *url = [[NSMutableString alloc] initWithString:self.IP];
    [url appendString:@"/igenda-777/webresources/igenda.usuario/"];
    [url appendString:_nomUsuario];
    
    //NSLog(@"URL ENVIADA %@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    //NSLog(@"GET usuario en login enviado");
    NSString *str = [[NSString alloc]initWithData:response1 encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSNumber *numVersion = [dic objectForKey:@"version"];
    [[(IGEAppDelegate *) [[UIApplication sharedApplication]delegate]settings]setVersionAgenda:numVersion];
    //return str;
}

- (void) errorDeRed{
    [self alertStatusWithButton:@"Error conectando al servidor, compruebe su conexión a internet" :@"Error de red" :0];
}

- (NSArray *) fetchEntitesArray: (NSString *) entityName {
    NSError *error = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription
        entityForName:entityName inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSArray *s = [_context executeFetchRequest:request error:&error];
    return s;
}






@end
