//
//  FavTableViewController.h
//  moglee
//
//  Created by Moglee on 21/05/15.
//  Copyright (c) 2015 Moglee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rotate;
@property (weak, nonatomic) IBOutlet UIView *rotateViews;
@end
