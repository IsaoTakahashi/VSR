//
//  CreateMapViewController.h
//  navigation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapAnnotationEntity.h"
#import "MapMasterEntity.h"

@protocol CreateMapViewControllerDelegate;

@interface CreateMapViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,
UIActionSheetDelegate,MKMapViewDelegate, CLLocationManagerDelegate,UIAlertViewDelegate> {
    IBOutlet MKMapView *mapView_;
    CLLocationManager *locationManager;
    int annotNumber;
    int mapNumber;
    MapAnnotationEntity* newAnnot;
    MapMasterEntity* mmEntity;
    
    UITextField* textField;
    NSMutableArray* annotEntityList;
    CLLocationCoordinate2D coordinateWithTap;
    
    id<CreateMapViewControllerDelegate> delegate;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView_;
@property (weak, nonatomic) IBOutlet UIToolbar *mapToolbar;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic, assign) int mapNumber;
@property (strong, nonatomic) MapMasterEntity* mmEntity;
@property (nonatomic, assign) CLLocationCoordinate2D coordinateWithTap;
@property (nonatomic, retain) id<CreateMapViewControllerDelegate> delegate;

// アクション
- (IBAction)showCameraSheet:(id)sender;
- (IBAction)createMap:(id)sender;
- (IBAction)tapOnMap:(id)sender;
- (IBAction)cancelCreating:(id)sender;

//
- (void)annotatePhoto:(MapAnnotationEntity*)annotEntity;

@end

@protocol CreateMapViewControllerDelegate <NSObject>

- (void) createdMap:(CreateMapViewController*)ctr;

@end
