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

#define kOFFSET_FOR_KEYBOARD 60.0

//@synthesize appDelegate;
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
        NSError *error = nil;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGESetting" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        IGESetting *set = [[context executeFetchRequest:request error:&error] firstObject];
        //NSLog(@"Version antes: %@", set.versionAgenda);
        self.contacto.id = set.numSeq;
        self.contacto.nombre = self.nombre.text;
        self.contacto.apellido1 = self.apellido1.text;
        self.contacto.apellido2 = self.apellido2.text;
        self.contacto.telefono = self.telefono.text;
        self.contacto.email = self.email.text;
        self.contacto.favorito = @0;
        self.contacto.estado = @0; //Recien creado
        int number = [set.numSeq intValue];
        number++;
        //set.numSeq = [NSNumber numberWithInt:number];
        [set setValue:[NSNumber numberWithInt:number] forKey:@"numSeq"];
        
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.foto.image)];
        self.contacto.imagen = imageData;
        [[groups objectAtIndex:[self.row integerValue]] addContactosObject:self.contacto];
        if (![(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] modified]){
            [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] setModified:true];
            NSNumber *vers = set.versionAgenda;
            int versint = [vers intValue] + 1;
            set.versionAgenda = [NSNumber numberWithInt:versint];
        }
        [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
        //NSLog(@"Version despues: %@", set.versionAgenda);
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
    
    /** Si no hay grupos creados, añade uno de la base de datos por defecto <Sin Grupo> **/
    if([groups count] == 0){
        IGEGroup *g = [NSEntityDescription insertNewObjectForEntityForName:@"IGEGroup" inManagedObjectContext:context];
        g.nombre = @"<Sin Grupo>";
        [groups addObject:g];
    }
    
    /** Guarda el contexto **/
    [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

- (void)viewDidLoad
{
    groups = [[NSMutableArray alloc]initWithArray:groups];
    self.doneButton.enabled = NO;//Se inhabilita hasta que el usuario introduzca nombre y teléfono
    [super viewDidLoad];
    [self loadInitialData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/******************** IMAGEN ********************/

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
        NSLog(@"eNTRA EN CHANGE BUTTON");
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

