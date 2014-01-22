//
//  IGEGroup.h
//  iGenda
//
//  Created by Diego Ojeda García on 22/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface IGEGroup : NSManagedObject

@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSSet *contactos;
@end

@interface IGEGroup (CoreDataGeneratedAccessors)

- (void)addContactosObject:(Contact *)value;
- (void)removeContactosObject:(Contact *)value;
- (void)addContactos:(NSSet *)values;
- (void)removeContactos:(NSSet *)values;

@end
