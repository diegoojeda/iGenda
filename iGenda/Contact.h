//
//  Contact.h
//  iGenda
//
//  Created by Escabia on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IGEGroup;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSString * apellido1;
@property (nonatomic, retain) NSString * apellido2;
@property (nonatomic, retain) NSString * telefono;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSData * imagen;
@property (nonatomic, retain) NSNumber * estado;    //0 creado, 1 editado, 2 ya en el servidor
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * favorito;
@property (nonatomic, retain) IGEGroup *newRelationship;

@end
