//
//  ViewController.h
//  navigation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Database.h"

@interface ViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    NSMutableArray* annotList;
    MapMasterEntity* mmEntity;
    
}
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (strong, nonatomic) MapMasterEntity* mmEntity;
@property (weak, nonatomic) IBOutlet UIImageView *PicureView;
@property (weak, nonatomic) IBOutlet MKMapView *NaviMapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *prevButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (weak, nonatomic) IBOutlet UINavigationItem *naviBar;
@property (weak, nonatomic) IBOutlet UIToolbar *naviToolbar;
@property (strong, nonatomic) IBOutlet MKUserTrackingBarButtonItem *userTrackingButton;
- (IBAction)clickPrev:(id)sender;
- (IBAction)clickNext:(id)sender;

@end
