//
//  IGEEditContactViewController.m
//  iGenda
//
//  Created by Máster INFTEL 09  on 18/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEEditContactViewController.h"
#import "IGEAppDelegate.h"
#import "Contact.h"
#import "IGEGroup.h"
#import "IGEPersonasTableViewController.h"



@interface IGEEditContactViewController ()


@property NSMutableArray *arrayContacts;

//PARA IMAGEN CONTATO. Controlador para buscar imagen en galería
@property (nonatomic) UIImagePickerController *imagePickerController;

@end


@implementation IGEEditContactViewController

#define kOFFSET_FOR_KEYBOARD 60.0

//@synthesize greetingPickerSelGroup;
@synthesize contacto = _contacto;
@synthesize greetingPickerSelGroup;
@synthesize grupo;



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.saveButton) return;
    
    NSLog(@"Nombre text %@",_contacto.nombre);
    if (self.nombre.text.length > 0)//Validación y almacenado
    {
        
        _contacto.nombre = self.nombre.text;
        _contacto.apellido1 = self.apellido1.text;
        _contacto.apellido2 = self.apellido2.text;
        _contacto.telefono = self.telefono.text;
        _contacto.email = self.email.text;
        _contacto.estado = @1;
        _contacto.grupo =[groups objectAtIndex:[self.row integerValue]];
        //_contacto.grupo.nombre = [[groups objectAtIndex:[self.row integerValue]] nombre];
        
        
        //falta el grupo
        
        //Conversión imagen UIImage a NSData, formato de la imagen del contacto
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.foto.image)];
        _contacto.imagen = imageData;
        NSError *error;
        NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSEntityDescription *desc = [NSEntityDescription entityForName:@"IGEContact" inManagedObjectContext:context];
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        [req setEntity:desc];

        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGESetting" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        IGESetting *set = [[context executeFetchRequest:request error:&error] firstObject];
        if (![(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] modified]){
            [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] setModified:true];
            NSNumber *vers = set.versionAgenda;
            int versint = [vers intValue] + 1;
            set.versionAgenda = [NSNumber numberWithInt:versint];
        }
        [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
        if ([[segue identifier] isEqualToString:@"unwindFromEditContact"]) {
            IGEShowContactViewController *controller = (IGEShowContactViewController *)[segue destinationViewController];
            [controller getContact:_contacto];
            //[controller reloadInputViews];
        }
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
    
    /** Añade grupos de core data **/
    for(int i=0; i<[array count]; i++){
        IGEGroup *g = [array objectAtIndex:i];
        [groups addObject:g];
    }
}

- (void)viewDidLoad
{
    groups = [[NSMutableArray alloc]initWithArray:groups];
    [super viewDidLoad];
    [self fetchContactEdit];
    [self loadInitialData];
    
    /** Carga la posición correcta Picker **/
    int row=0;
    for(int i=0; i<groups.count; i++){
        if([[groups objectAtIndex:i] nombre] == _contacto.grupo.nombre)
            row = i;
    }
    
    [self.greetingPickerSelGroup selectRow:row inComponent:0 animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//*********IMÁGEN*********

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

// Cuando cancelas la  búsqueda de la imagen, el controlador llama a este método
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//************************

//Ocultar el teclado
- (IBAction)backgroundClick:(id) sender {
    [self.view endEditing:YES];
    
}

//Oculta el teclado haciendo caso omiso al return
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void) getContactEdit:(Contact *)contacto{
    _contacto = contacto;
}

- (IBAction) fetchContactEdit
{
    
    self.nombre.text = _contacto.nombre;
    self.apellido1.text = _contacto.apellido1;
    self.apellido2.text = _contacto.apellido2;
    self.telefono.text = _contacto.telefono;
    self.email.text = _contacto.email;
    
    UIImage *i =[[UIImage alloc] initWithData:_contacto.imagen];
    self.foto.image=i;
    
}

/*********** PICKER *********/
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
            self.saveButton.enabled = NO;
        }
        else{
            self.saveButton.enabled = YES;
        }
    }
    else
        self.saveButton.enabled = NO;
}

- (IBAction)changeTelefono:(id)sender{
    if(self.nombre.text.length > 0 && self.telefono.text.length > 0){
        if([groups count] == 0){
            self.saveButton.enabled = NO;
        }
        else{
            self.saveButton.enabled = YES;
        }
    }
    else
        self.saveButton.enabled = NO;
}

//****************SUBIR VISTA CUANDO APARECE TECLADO************************

//Según empiece la posición de la vista, si está >=0 es que el teclado está y se tiene que mover la vista y viceversa
//Para esconder el teclado igual
-(void)keyboardWillShow {
    
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}


//Método que mueve la vista según está el teclado o no, y la mueve el offset definido arriba
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

//Notificaciones de que el teclado se tiene que mover o esconder, mientras la vista está visible, por eso está en el willapperar
- (void)viewWillAppear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//Mientras la vista no está visible quitamos las notificaciones de mostrar y esconder teclado
- (void)viewWillDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


@end
