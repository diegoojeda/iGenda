//
//  IGEAppDelegate.h
//  iGenda
//
//  Created by Máster INFTEL 11 on 15/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface IGEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;//

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property Contact *seleccionado; //Contacto seleccionado para Ver/Editar

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
