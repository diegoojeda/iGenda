//
//  IGEPersonasFromGrupoViewController.h
//  iGenda
//
//  Created by Diego Ojeda García on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGEGroup.h"
#import "IGEShowContactViewController.h"

@interface IGEPersonasFromGrupoViewController : UITableViewController

@property NSString *nombreGrupo;
@property NSArray *contactosGrupo;

-(void) getInfo: (NSArray* ) grupo andName: (NSString *) name;

@end
