//
//  IGESettingsViewController.m
//  iGenda
//
//  Created by Diego Ojeda García on 18/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGESettingsViewController.h"

@interface IGESettingsViewController ()
- (IBAction)deleteLoginData:(id)sender;

@end

@implementation IGESettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (IBAction)deleteLoginData:(id)sender {
    NSManagedObjectContext *context = [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; //Recupera contexto del Delegate
    NSError *error = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IGESetting" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSArray *s = [context executeFetchRequest:request error:&error];
    for (IGESetting *set in s){
        NSLog(@"Borro ");
        //[context deleteObject:set];
    }
    //IGESetting *set = [s objectAtIndex:0];
    //NSLog(@"logging out:");
    
    //set.usuario = @"";
    
    //Guardamos el contexto
    [(IGEAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];}
@end
