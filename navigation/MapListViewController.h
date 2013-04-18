//
//  MapListViewController.h
//  Realation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateMapViewController.h"

@interface MapListViewController : UITableViewController<CreateMapViewControllerDelegate> {
    NSMutableArray* mapList;
}

@property (strong, nonatomic) NSMutableArray* mapList;
- (IBAction)deleteMapDatas:(id)sender;

@end
