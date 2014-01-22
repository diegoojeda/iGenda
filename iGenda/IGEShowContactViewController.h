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
#import <MessageUI/MFMailComposeViewController.h>


@interface IGEShowContactViewController : UIViewController <MFMailComposeViewControllerDelegate>

/** Label **/
@property (nonatomic, strong) IBOutlet UILabel *nombre_L;
@property (nonatomic, strong) IBOutlet UILabel *movil_L;
@property (nonatomic, strong) IBOutlet UILabel *email_L;
@property (nonatomic, strong) IBOutlet UIButton *star_L;
@property (nonatomic, strong) IBOutlet NSNumber *estado;
@property (nonatomic, strong) IBOutlet UILabel *grupo_L;



@property (nonatomic, strong) IBOutlet UIImageView *image_IV;


@property Contact *contacto; //Contacto seleccionado
@property NSString *grupo;

- (IBAction)sendEmail:(id)sender;

- (IBAction)changeFavorito:(id)sender;


- (void) getContact:(Contact *)contacto; //GetContact desde la tabla
@end
