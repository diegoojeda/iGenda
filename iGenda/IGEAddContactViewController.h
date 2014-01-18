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

@interface IGEAddContactViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
    //Añado al View Controller estos dos protocolos para el el ImagePickerController, para navegación por la galería y manejo de datos (necesario)

@property Contact *contacto;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IGEAppDelegate *appDelegate;

@end
