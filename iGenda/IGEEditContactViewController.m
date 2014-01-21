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



@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property NSMutableArray *arrayContacts;

//PARA IMAGEN CONTATO. Controlador para buscar imagen en galería
@property (nonatomic) UIImagePickerController *imagePickerController;

@end


@implementation IGEEditContactViewController

@synthesize greetingPickerSelGroup;



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.saveButton) return;
    
    if (self.nombre.text.length > 0)//Validación y almacenado
    {
        
        
        _contacto.nombre = self.nombre.text;
        _contacto.apellido1 = self.apellido1.text;
        _contacto.apellido2 = self.apellido2.text;
        _contacto.telefono = self.telefono.text;
        _contacto.email = self.email.text;
        
        //falta el grupo
        
        //Conversión imagen UIImage a NSData, formato de la imagen del contacto
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.foto.image)];
        _contacto.imagen = imageData;
        NSError *error;
        NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSEntityDescription *desc = [NSEntityDescription entityForName:@"IGEContact" inManagedObjectContext:context];
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        [req setEntity:desc];
        NSArray *contactos = [context executeFetchRequest:req error:&error];
        for (Contact *c in contactos) {
            if (c.id == _contacto.id){
                //NSLog(@"ID: %@", c.id);
                [c setValue:_contacto.nombre forKey:@"nombre"];
            }
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

- (void)viewDidLoad
{
    countryNames = [[NSMutableArray alloc]initWithObjects:@"Grupo1",@"Grupo2",@"Grupo3", @"Grupo4",@"Grupo5",@"Grupo6",nil];//Habria que cargar aqui todos los grupos
    [super viewDidLoad];
    [self fetchContactEdit];
    

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
    self.grupo = [countryNames objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [countryNames count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [countryNames objectAtIndex:row];
}

//************************

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



@end
