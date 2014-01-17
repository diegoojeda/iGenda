//
//  IGEShowContactViewController.m
//  iGenda
//
//  Created by Escabia on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEShowContactViewController.h"

@interface IGEShowContactViewController ()

@end

@implementation IGEShowContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.greetingNombre.text = @"HOLA CH";
    }
    return self;
}

- (IBAction) fetchContact
{
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.greetingNombre.text = self.appDelegate.seleccionado.nombre;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchContact];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
