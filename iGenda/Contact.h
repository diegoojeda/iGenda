//
//  Contact.h
//  iGenda
//
//  Created by Diego Ojeda García on 22/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IGEGroup;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * apellido1;
@property (nonatomic, retain) NSString * apellido2;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * estado;
@property (nonatomic, retain) NSNumber * favorito;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSData * imagen;
@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSString * telefono;
@property (nonatomic, retain) IGEGroup *grupo;

@end
