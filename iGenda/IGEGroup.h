//
//  IGEGroup.h
//  iGenda
//
//  Created by Máster INFTEL 12 on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface IGEGroup : NSManagedObject

@property (nonatomic, retain) NSString *nombre;
@property (nonatomic, retain) NSSet *newRelationship;
@end

@interface IGEGroup (CoreDataGeneratedAccessors)

- (void)addNewRelationshipObject:(Contact *)value;
- (void)removeNewRelationshipObject:(Contact *)value;
- (void)addNewRelationship:(NSSet *)values;
- (void)removeNewRelationship:(NSSet *)values;

@end
