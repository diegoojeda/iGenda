//
//  IGEShowContactViewController.m
//  iGenda
//
//  Created by Escabia on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEShowContactViewController.h"
#import "IGEEditContactViewController.h"
#import <MessageUI/MessageUI.h>


@interface IGEShowContactViewController ()<
MFMailComposeViewControllerDelegate,
UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *atrasButton;
@property (nonatomic, weak) IBOutlet UILabel *feedbackMsg;
@end

@implementation IGEShowContactViewController

@synthesize contacto = _contacto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (IBAction) fetchContact
{
    static NSString *formatString = @"%@%@%@%@%@";
    NSString *fullname = [NSString stringWithFormat:formatString,_contacto.nombre,@" ",_contacto.apellido1,@" ",_contacto.apellido2];
    self.nombre_L.text = fullname;
    self.movil_L.text = _contacto.telefono;
    self.email_L.text = _contacto.email;
    
    
    self.image_IV.image=[UIImage imageWithData:_contacto.imagen];
    
    if([_contacto.favorito  isEqual: @0]){
        self.star_L.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"star.png"]];
    }
    else{
        self.star_L.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"star_sel.png"]];
    }
}


-(IBAction)callPhone:(id)sender {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString: self.contacto.telefono]];
   // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:639970861"]];
}

//- (IBAction)sendEmail:(id)sender {
//    MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
//    [composer setMailComposeDelegate:self];
//    if ([MFMailComposeViewController canSendMail]){
//        [composer setToRecipients:[NSArray arrayWithObject:self.contacto.email]];
//        [composer setSubject:@"Put your subject here"];
//        [composer setMessageBody:@"Put your message here" isHTML:NO];
//        [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//        [self presentViewController:composer animated:YES completion:NULL];
//    }
//    else{
//        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error has ocurred" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }
//}

//- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
//{
//    if(error){
//        UIAlertView *alert =[[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error has ocurred" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
//        [alert show];
//        [self dismissViewControllerAnimated:YES completion:nil];
//
//    }else {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//}

//Probando las nuevas funciones para enviar email

- (IBAction)showMailPicker:(id)sender
{
    // You must check that the current device can send email messages before you
    // attempt to create an instance of MFMailComposeViewController.  If the
    // device can not send email messages,
    // [[MFMailComposeViewController alloc] init] will return nil.  Your app
    // will crash when it calls -presentViewController:animated:completion: with
    // a nil view controller.
    if ([MFMailComposeViewController canSendMail])
        // The device can send email.
    {
        [self displayMailComposerSheet];
    }
    else
        // The device can not send email.
    {
        self.feedbackMsg.hidden = NO;
		self.feedbackMsg.text = @"Device not configured to send mail.";
    }
}

// -------------------------------------------------------------------------------
//	displayMailComposerSheet
//  Displays an email composition interface inside the application.
//  Populates all the Mail fields.
// -------------------------------------------------------------------------------
- (void)displayMailComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Put here your subject"];
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:self.contacto.email];
	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", nil];
	NSArray *bccRecipients = [NSArray arrayWithObject:@"third@example.com"];
	
	[picker setToRecipients:toRecipients];
	[picker setCcRecipients:ccRecipients];
	[picker setBccRecipients:bccRecipients];
	
	// Fill out the email body text
	NSString *emailBody = @"Put your message body";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentViewController:picker animated:YES completion:NULL];
}

// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	self.feedbackMsg.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			self.feedbackMsg.text = @"Result: Mail sending canceled";
			break;
		case MFMailComposeResultSaved:
			self.feedbackMsg.text = @"Result: Mail saved";
			break;
		case MFMailComposeResultSent:
			self.feedbackMsg.text = @"Result: Mail sent";
			break;
		case MFMailComposeResultFailed:
			self.feedbackMsg.text = @"Result: Mail sending failed";
			break;
		default:
			self.feedbackMsg.text = @"Result: Mail not sent";
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:NULL];
}


////////////////////////////////////Fin de la prueba

- (IBAction)changeFavorito:(id)sender{//NO ESTA BIEN
    if([_contacto.favorito  isEqual: @0]){
        _contacto.favorito = @1;
        self.star_L.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"star_sel.png"]];
    }
    else{
        _contacto.favorito = @0;
        self.star_L.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"star.png"]];
    }
    [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchContact];
}


-(void) viewWillAppear:(BOOL)animated{
    static NSString *formatString = @"%@%@%@%@%@";
    NSString *fullname = [NSString stringWithFormat:formatString,_contacto.nombre,@" ",_contacto.apellido1,@" ",_contacto.apellido2];
    self.nombre_L.text = fullname;
    self.movil_L.text = _contacto.telefono;
    self.email_L.text = _contacto.email;
    //self.grupo_L.text = [_contacto.newRelationship nombre];
    self.image_IV.image=[UIImage imageWithData:_contacto.imagen];
    //NSLog(@"GRUPO: %@", _contacto.newRelationship.nombre);
    [self.view setNeedsDisplay];
}

- (IBAction)unwindFromEditToShowContact:(UIStoryboardSegue *)segue{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getContact:(Contact *)contacto{
    _contacto = contacto;
    
    
}


///**
// Prepara para la transición de la info del contacto a su edición
// */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ContactEdit"]) {
        IGEEditContactViewController *controller = (IGEEditContactViewController *)[[segue destinationViewController] topViewController];
        [controller getContactEdit:_contacto];
    }
    
}




@end
