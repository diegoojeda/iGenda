//
//  IGERootViewController.m
//  iGenda
//
//  Created by Diego Ojeda García on 18/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGERootViewController.h"

@interface IGERootViewController ()

@end

@implementation IGERootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated{
    //Fetch user logged or not
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGESetting" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSArray *s = [context executeFetchRequest:request error:&error];
    if (s == nil || [s count] == 0){
        NSLog(@"User vacío");
        [self performSegueWithIdentifier:@"ToLoginSegue" sender:self];
    }
    else{
        NSLog(@"User encontrado");
        [self performSegueWithIdentifier:@"ToTabsSegue" sender:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
