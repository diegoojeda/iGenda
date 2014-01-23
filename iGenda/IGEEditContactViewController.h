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

@interface IGEEditContactViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>{
    UIPickerView *greetingPickerSelGroup;
    NSMutableArray *groups;
}

@property Contact *contacto;
@property IGEGroup *grupo;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UIPickerView *greetingPickerSelGroup;

- (IBAction)backgroundClick:(id)sender;

/** TextField **/
@property (weak, nonatomic) IBOutlet UITextField *telefono;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIImageView *foto;
@property (weak, nonatomic) IBOutlet UITextField *apellido2;
@property (weak, nonatomic) IBOutlet UITextField *apellido1;
@property (weak, nonatomic) IBOutlet UITextField *nombre;

@property NSNumber *row;;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;


- (void) getContactEdit:(Contact *)contacto;

@end
