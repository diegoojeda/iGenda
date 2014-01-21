//
//  IGEShowContactViewController.m
//  iGenda
//
//  Created by Escabia on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEShowContactViewController.h"
#import "IGEEditContactViewController.h"

@interface IGEShowContactViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *atrasButton;
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:639970861"]];
}

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
