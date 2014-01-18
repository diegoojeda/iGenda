//
//  IGEEditContactViewController.h
//  iGenda
//
//  Created by Máster INFTEL 09  on 18/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface IGEEditContactViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
//Añado al View Controller estos dos protocolos para el el ImagePickerController, para navegación por la galería y manejo de datos (necesario)

@property Contact *contacto;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
