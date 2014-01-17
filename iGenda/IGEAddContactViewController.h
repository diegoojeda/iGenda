//
//  IGEAddContactViewController.h
//  iGenda
//
//  Created by Máster INFTEL 11 on 16/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface IGEAddContactViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property Contact *contacto;

@end
