//
//  IGEShowContactCell.m
//  iGenda
//
//  Created by Máster INFTEL 09  on 17/01/14.
//  Copyright (c) 2014 UMA. All rights reserved.
//

#import "IGEShowContactCell.h"

@implementation IGEShowContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(IBAction)changeColor:(id)sender
{
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    
    if (btn.isEnabled)
    {
        [btn setTintColor:[UIColor blueColor]];
        
    }
    else
    {
        [btn setTintColor:[UIColor grayColor]];
    }
    
}

@end
