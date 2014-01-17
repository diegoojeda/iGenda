//
//  IGEShowContactViewController.h
//  iGenda
//
//  Created by Escabia on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGEAppDelegate.h"


@interface IGEShowContactViewController : UIViewController

/** Label **/
@property (nonatomic, strong) IBOutlet UILabel *greetingNombre;
@property (nonatomic, strong) IBOutlet UILabel *greetingMovil;
@property (nonatomic, strong) IBOutlet UILabel *greetingEmail;
@property (nonatomic, strong) IBOutlet UIButton *greetingStar;





@property Contact *contacto; //Contacto seleccionado


- (IBAction) fetchContact; //Función de consulta
- (IBAction)changeFavorito:(id)sender;

- (void) getContact:(Contact *)contacto; //GetContact desde la tabla

@end
