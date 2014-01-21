//
//  IGEEditContactViewController.h
//  iGenda
//
//  Created by Máster INFTEL 09  on 18/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "IGEAppDelegate.h"

@interface IGEEditContactViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    UIPickerView *greetingPickerSelGroup;
    NSMutableArray *countryNames;
}
//Añado al View Controller estos dos protocolos para el el ImagePickerController, para navegación por la galería y manejo de datos (necesario)

@property Contact *contacto;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)backgroundClick:(id)sender;
@property (nonatomic, strong) IBOutlet UIPickerView *greetingPickerSelGroup;

/** TextField **/
@property (weak, nonatomic) IBOutlet UITextField *telefono;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIImageView *foto;
@property (weak, nonatomic) IBOutlet UITextField *apellido2;
@property (weak, nonatomic) IBOutlet UITextField *apellido1;
@property (weak, nonatomic) IBOutlet UITextField *nombre;

- (void) getContactEdit:(Contact *)contacto;

@end
