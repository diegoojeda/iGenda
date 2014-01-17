//
//  IGESetting.h
//  iGenda
//
//  Created by Escabia on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IGESetting : NSManagedObject

@property (nonatomic, retain) NSString * usuario;
@property (nonatomic, retain) NSString * clave;

@end
