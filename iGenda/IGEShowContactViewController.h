//
//  IGEShowContactViewController.h
//  iGenda
//
//  Created by Escabia on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGEAppDelegate.h"
#import "IGEGroup.h"


@interface IGEShowContactViewController : UIViewController

/** Label **/
@property (nonatomic, strong) IBOutlet UILabel *greetingNombre;
@property (nonatomic, strong) IBOutlet UILabel *greetingApellido1;
@property (nonatomic, strong) IBOutlet UILabel *greetingApellido2;
@property (nonatomic, strong) IBOutlet UILabel *greetingMovil;
@property (nonatomic, strong) IBOutlet UILabel *greetingEmail;
@property (nonatomic, strong) IBOutlet UILabel *greetingGrupo;
@property (nonatomic, strong) IBOutlet UIButton *greetingStar;


@property (nonatomic, strong) IBOutlet UIImageView *greetingImage;





@property Contact *contacto; //Contacto seleccionado


- (IBAction)changeFavorito:(id)sender;


- (void) getContact:(Contact *)contacto; //GetContact desde la tabla

@end
