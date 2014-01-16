//
//  Contact.h
//  iGenda
//
//  Created by Escabia on 16/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IGEContact : NSManagedObject

@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSString * apellido1;
@property (nonatomic, retain) NSString * apellido2;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * telefono;
@property (nonatomic, retain) NSData * imagen;

@end
