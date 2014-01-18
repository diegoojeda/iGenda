//
//  IGESetting.h
//  iGenda
//
//  Created by Máster INFTEL 12 on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IGESetting : NSManagedObject

@property (nonatomic, retain) NSString * clave;
@property (nonatomic, retain) NSString * usuario;

@end
