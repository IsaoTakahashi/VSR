//
//  ViewController.m
//  navigation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "ViewController.h"
#import "FileIO.h"
#import "ImageAnnotation.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

static UIImage* naviImage = nil;
static Boolean isHighlighted = false;
static MKPolylineView* baseLinesView = nil;
static MKPolylineView* highlightedLineView = nil;
static MKCircleView* targetCircleView = nil;
static MapAnnotationEntity* targetAnnot = nil;
static int currentAnnotNum;
static int routeCount;

@implementation ViewController
@synthesize mmEntity;
@synthesize PicureView;
@synthesize NaviMapView;
@synthesize prevButton;
@synthesize nextButton;
@synthesize naviBar;
@synthesize naviToolbar;
@synthesize userTrackingButton;

+ (UIImage*) getNaviImageInstance {
    if(naviImage == nil) {
        naviImage = [[UIImage alloc] init];
    }
    return naviImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load annotList
    annotList = [[Database getInstance] getAnnotationListWithMapNo:mmEntity.mapNo];
    routeCount = annotList.count;
    if(routeCount > 0) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (1/%d)",mmEntity.title,routeCount];
        
        [self showNaviPicture:[annotList objectAtIndex:0]];
    }
    
	// Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation]; //位置情報の取得
    NaviMapView.showsUserLocation = YES;
    NaviMapView.delegate = self;
    MKUserTrackingBarButtonItem* trackButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:NaviMapView];
    NSArray* array = naviToolbar.items;
    int i= 0;
    for(UIBarButtonItem* item in array) {
        if([item.title isEqualToString:@"Track"]) {
            break;
        }
        i++;
    }
    
    NSMutableArray* mArray = [NSMutableArray arrayWithArray:array];
    [mArray replaceObjectAtIndex:i withObject:trackButton];
    [naviToolbar setItems:[NSArray arrayWithArray:(NSArray*)mArray]];
    //[NaviMapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    
    //マップ描画処理
    for(MapAnnotationEntity* entity in annotList) {
        [self annotatePin:entity];
    }
    currentAnnotNum = 0;
    [prevButton setEnabled:false];
    [self drawBaseLines];
    //[self drawHigilightedLine:currentAnnotNum];
    [self drawTargetCircle:currentAnnotNum];
    [self setMapRegion:[annotList objectAtIndex:0] destAnnot:[annotList objectAtIndex:1]];
    
    //Layer
    NaviMapView.layer.cornerRadius = 2.0;
    NaviMapView.layer.borderWidth = 2.0;
    NaviMapView.layer.borderColor = [[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5] CGColor];
    
    self.navigationController.navigationBar.tintColor = [UIColor brownColor];
    naviToolbar.tintColor = [UIColor brownColor];
    
    //最初のRegionがおかしいので応急処置
    //[self clickNext:nil];
    //[self clickPrev:nil];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setPicureView:nil];
    [self setNaviMapView:nil];
    [self setPrevButton:nil];
    [self setNextButton:nil];
    [self setNaviToolbar:nil];
    [self setNaviBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark -
#pragma mark - ナビ画像処理
- (void) showNaviPicture:(MapAnnotationEntity*)annot {
    UIImage* image = [UIImage imageWithData:[FileIO file2data:annot.imageUri subDir:@"mapImage"]];
    
    PicureView.image = image;
    [PicureView setNeedsDisplay];
    NSLog(@"imate:%@",annot.imageUri);
}

#pragma mark -
#pragma mark - アノテーション処理
-(MKAnnotationView*)mapView:(MKMapView*) mapView viewForAnnotation:(id )annotation
{
    if (![annotation isKindOfClass:[ImageAnnotation class]]
        && annotation == mapView.userLocation) {
        NSLog(@"are");
        return nil;
    }
    
    MKPinAnnotationView *annotationView;
    
    NSString* identifier = [NSString stringWithFormat:@"Pin_%d",targetAnnot.id_];
    
    annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(nil == annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    /*
    NSLog(@"file:%@",targetAnnot.imageUri);
    if([FileIO existsFile:targetAnnot.imageUri subDir:@"mapImage"]) {
        NSLog(@"file exists.");
    }
    */
    //annotationView.image = [UIImage imageWithData:[FileIO file2data:newAnnot.imageUri subDir:@"mapImage"]];
    //if(annotationView.image == nil) {
    //    NSLog(@"image not found");
    //}
    annotationView.animatesDrop = YES; //このプロパティでアニメーションドロップを設定
    annotationView.canShowCallout = YES; //このプロパティを設定してコールアウト（文字を表示する吹出し）を表示
    annotationView.annotation = annotation; //このメソッドで設定したアノテーションをannotationViewに再追加してreturnで返す
    return annotationView;
}

- (void)annotatePin:(MapAnnotationEntity*)annotEntity
{
    // アノテーションを作成する
    ImageAnnotation*  annotation;
    annotation = [[ImageAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(annotEntity.latitude, annotEntity.longitude)];
    annotation.title = annotEntity.imageUri;
    
    // アノテーションを追加する
    targetAnnot = annotEntity;
    [NaviMapView addAnnotation:annotation];
    //[self drawLines];
}

#pragma mark -
#pragma mark - マップ描画処理

- (void) setMapRegion:(MapAnnotationEntity*)depAnnot destAnnot:(MapAnnotationEntity*)destAnnot {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((depAnnot.latitude + destAnnot.latitude)/2.0, (depAnnot.longitude + destAnnot.longitude)/2.0);
    double spanLat = destAnnot.latitude - depAnnot.latitude;
    if(spanLat < 0) spanLat = -spanLat;
    double spanLng = destAnnot.longitude - depAnnot.longitude;
    if(spanLng < 0) spanLng = -spanLng;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(spanLat*1.6, spanLng*1.6);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    //[NaviMapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    [NaviMapView setRegion:[NaviMapView regionThatFits:region] animated:YES];
    
    NSLog(@"center lat:%f  lng:%f",center.latitude,center.longitude);
}

- (MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if([overlay isKindOfClass:[MKCircle class]]) {
        if(targetCircleView != nil) {
            [NaviMapView removeOverlay:targetCircleView.overlay];
        }
        targetCircleView = [[MKCircleView alloc] initWithOverlay:overlay];
        MKCircleView* view = targetCircleView;
        view.strokeColor = [UIColor redColor];
        view.lineWidth = 5.0;
        return view;
    }else {
        MKPolylineView* view;
        if(isHighlighted) {
            if(highlightedLineView != nil) {
                [NaviMapView removeOverlay:highlightedLineView.overlay];
                //highlightedLineView = [[MKPolylineView alloc] initWithOverlay:overlay];
            }
            highlightedLineView = [[MKPolylineView alloc] initWithOverlay:overlay];
            view = highlightedLineView;
            view.strokeColor = [UIColor greenColor];
            view.lineWidth = 7.0;
        } else {
            if(baseLinesView != nil) {
                [NaviMapView removeOverlay:baseLinesView.overlay];
            }
            baseLinesView = [[MKPolylineView alloc] initWithOverlay:overlay];
            view = baseLinesView;
            view.strokeColor = [UIColor blueColor];
            view.lineWidth = 5.0;
        }
        return view;
    }
    
}

- (void) drawBaseLines {
    int count = annotList.count;
    CLLocationCoordinate2D coords[count];
    
    for (int i=0;i<count;i++) {
        MapAnnotationEntity* entity = [annotList objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(entity.latitude, entity.longitude);
    }
    
    MKPolyline* line = [MKPolyline polylineWithCoordinates:coords count:count];
    [NaviMapView addOverlay:line];
}

- (void) drawHigilightedLine:(int)annotNum {
    CLLocationCoordinate2D coords[2];
    
    for (int i=0;i<2;i++) {
        MapAnnotationEntity* entity = [annotList objectAtIndex:i+annotNum];
        coords[i] = CLLocationCoordinate2DMake(entity.latitude, entity.longitude);
    }
    
    MKPolyline* line = [MKPolyline polylineWithCoordinates:coords count:2];
    isHighlighted = true;
    [NaviMapView addOverlay:line];
}

- (void) drawTargetCircle:(int)annotNum{
    MapAnnotationEntity* entity = [annotList objectAtIndex:annotNum];
    MKCircle* circle = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(entity.latitude, entity.longitude) radius:4];
    [NaviMapView addOverlay:circle];
}

#pragma mark -
#pragma mark - デバイス回転
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return false;
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [PicureView setFrame:CGRectMake(0, 0, 960/2, 640/2)];
        [self.view bringSubviewToFront:PicureView];
        [NaviMapView removeFromSuperview];
    } else if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        [PicureView setFrame:CGRectMake(0, 0, 320/2, 213)];
        [self.view bringSubviewToFront:PicureView];
        [self.view addSubview:NaviMapView];
    }
}

- (IBAction)clickPrev:(id)sender {
    if(currentAnnotNum > 0) {
        currentAnnotNum--;
        //[self drawBaseLines];
        if(currentAnnotNum > 0){
            [self drawHigilightedLine:currentAnnotNum-1];
            [self setMapRegion:[annotList objectAtIndex:currentAnnotNum-1] destAnnot:[annotList objectAtIndex:currentAnnotNum]];
        } else {
            [self setMapRegion:[annotList objectAtIndex:0] destAnnot:[annotList objectAtIndex:1]];
        }
        [self drawTargetCircle:currentAnnotNum];
        
    }
    
    if(currentAnnotNum == 0){
        [sender setEnabled:false];
    }
    
    [nextButton setEnabled:true];
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%d/%d)",
                                 mmEntity.title,currentAnnotNum+1,routeCount];
    [self showNaviPicture:[annotList objectAtIndex:currentAnnotNum]];
}

- (IBAction)clickNext:(id)sender {
    if(currentAnnotNum < routeCount - 1){
        currentAnnotNum++;
        //[self drawBaseLines];
        [self drawHigilightedLine:currentAnnotNum-1];
        [self drawTargetCircle:currentAnnotNum];
        [self setMapRegion:[annotList objectAtIndex:currentAnnotNum-1] destAnnot:[annotList objectAtIndex:currentAnnotNum]];
    }
    
    if(currentAnnotNum == routeCount - 1) {
        [sender setEnabled:false];
    }
    
    [prevButton setEnabled:true];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%d/%d)",
                                 mmEntity.title,currentAnnotNum+1,routeCount];
    [self showNaviPicture:[annotList objectAtIndex:currentAnnotNum]];
}
@end
