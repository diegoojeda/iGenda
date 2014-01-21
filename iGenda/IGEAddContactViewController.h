//
//  IGEAddContactViewController.h
//  iGenda
//
//  Created by Máster INFTEL 11 on 16/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGEAppDelegate.h"
#import "Contact.h"
#import "IGEGroup.h"

@interface IGEAddContactViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>{
    UIPickerView *greetingPickerSelGroup;
    NSMutableArray *groups;
}
//Añado al View Controller estos dos protocolos para el el ImagePickerController, para navegación por la galería y manejo de datos (necesario)

@property Contact *contacto;
@property IGEGroup *grupo;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IGEAppDelegate *appDelegate;

@property (nonatomic, strong) IBOutlet UIPickerView *greetingPickerSelGroup;

/* Validación */

- (IBAction)changeNombre:(id)sender;
- (IBAction)changeTelefono:(id)sender;
- (IBAction)backgroundClick:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *telefono;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIImageView *foto;
@property (weak, nonatomic) IBOutlet UITextField *apellido2;
@property (weak, nonatomic) IBOutlet UITextField *apellido1;
@property (weak, nonatomic) IBOutlet UITextField *nombre;
@property NSNumber *row;;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;


@end
