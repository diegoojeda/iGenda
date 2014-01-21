//
//  IGEAddContactViewController.m
//  iGenda
//
//  Created by Máster INFTEL 11 on 16/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEAddContactViewController.h"
#import "IGEAppDelegate.h"
#import "Contact.h"


@interface IGEAddContactViewController ()

//PARA IMAGEN CONTATO. Controlador para buscar imagen en galería
@property (nonatomic) UIImagePickerController *imagePickerController;

@end



@implementation IGEAddContactViewController

@synthesize appDelegate;
@synthesize greetingPickerSelGroup;
@synthesize contacto;
@synthesize grupo;

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if (sender != self.doneButton) return;
    
    
    if (self.nombre.text.length > 0)//Validación y almacenado
    {
        NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

        self.contacto = [NSEntityDescription insertNewObjectForEntityForName:@"IGEContact" inManagedObjectContext:context];
        
        //Esto solo almacena un campo, nombre, lo demas es lo de la persistencia
        appDelegate = [UIApplication sharedApplication].delegate;
        if(appDelegate.seqId == NULL){ //Si la secuencia no está creada, se crea
            appDelegate.seqId = [NSNumber numberWithInt:1];
        }else{ //En otro caso, se incrementa
            int value = [appDelegate.seqId intValue];
            appDelegate.seqId = [NSNumber numberWithInt:value + 1];
        }
        
        self.contacto.id = appDelegate.seqId;
        self.contacto.nombre = self.nombre.text;
        self.contacto.apellido1 = self.apellido1.text;
        self.contacto.apellido2 = self.apellido2.text;
        self.contacto.telefono = self.telefono.text;
        self.contacto.email = self.email.text;
        self.contacto.favorito = @0;
        self.contacto.estado = 0; //Recien creado
        NSLog(@"Se ha añadido un contacto con grupo---> %@", [[groups objectAtIndex:[self.row integerValue]] nombre]);
        
       
        //Conversión imagen UIImage a NSData, formato de la imagen del contacto
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.foto.image)];
        self.contacto.imagen = imageData;
        
        
        /** Añade contacto a un grupo *
        if([groups objectAtIndex:[self.row integerValue]] != NULL)
            [[groups objectAtIndex:[self.row integerValue]] addNewRelationshipObject:self.contacto];
        else
            NSLog(@"NO SE ASIGNA GRUPO");*/
        
        /** Guarda el contexto **/
        [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
        
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

- (void)loadInitialData {
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGEGroup" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    
    
    groups = [[NSMutableArray alloc] init];//Habria que cargar aqui todos los grupos
    
    for(int i=0; i<[array count]; i++){
        IGEGroup *g = [array objectAtIndex:i];
        [groups addObject:g];
    }
}

- (void)viewDidLoad
{
    self.doneButton.enabled = NO;//Se inhabilita hasta que el usuario introduzca nombre y teléfono
    [super viewDidLoad];
    [self loadInitialData];
    if([groups count] == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Aviso" message:@"No puede añadir contactos. Debe crear al menos un grupo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/******************** IMÁGEN ********************/

//Acción cuando pulsar botón buscar foto
- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

//ShowImagePickerForPhotoPicker llama a este método que configura el controlador y le da el control
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    //Guardo imagen y llama al finish and update
    [self.foto setImage:image];
    [self finishAndUpdate];
}



/******************** PICKER ********************/
#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.row = [[NSNumber alloc] initWithInteger:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [groups count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [[groups objectAtIndex:row] nombre];
} 


/******************** VALIDACIÓN *****************/
- (IBAction)changeNombre:(id)sender{

    if(self.nombre.text.length > 0 && self.telefono.text.length > 0){
        if([groups count] == 0){
            self.doneButton.enabled = NO;
        }
        else{
            self.doneButton.enabled = YES;
        }
    }
    else
        self.doneButton.enabled = NO;
}

- (IBAction)changeTelefono:(id)sender{
    if(self.nombre.text.length > 0 && self.telefono.text.length > 0){
        if([groups count] == 0){
            self.doneButton.enabled = NO;
        }
        else{
            self.doneButton.enabled = YES;
        }
    }
    else
        self.doneButton.enabled = NO;
}

- (IBAction)backgroundClick:(id)sender {
    [self.view endEditing:YES];
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end

