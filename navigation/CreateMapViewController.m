//
//  CreateMapViewController.m
//  navigation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "CreateMapViewController.h"
#import "Database.h"
#import "FileIO.h"
#import "ImageAnnotation.h"



@interface CreateMapViewController ()

@end

static UIImagePickerController *pickerCtr;
static Boolean isInitializedMapRegion = false;
static Boolean isPinWithTap = false;
static MKPolylineView* baseLinesView = nil;

@implementation CreateMapViewController

@synthesize mapView_;
@synthesize mapToolbar;
@synthesize locationManager;
@synthesize mapNumber;
@synthesize mmEntity;
@synthesize coordinateWithTap;
@synthesize delegate;

+ (UIImagePickerController*)defaultPicker {
    if(pickerCtr == nil) {
        pickerCtr = [[UIImagePickerController alloc] init];
    }
    NSLog(@"default Picker");
    return pickerCtr;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation]; //位置情報の取得
    mapView_.showsUserLocation = YES;
    mapView_.delegate = self;
    mapNumber = [[Database getInstance] getMapListCount];
    if(mapNumber < 0) {
        mapNumber = 0;
    }
    annotNumber = 0;
    
    mmEntity = [[MapMasterEntity alloc] init];
    mmEntity.mapNo = mapNumber;
    mmEntity.title = @"";
    mmEntity.depName = @"";
    mmEntity.destName = @"";
    
    annotEntityList = [[NSMutableArray alloc] init];
    
    mapToolbar.tintColor = [UIColor blackColor];
}

//表示領域の設定
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    //初回だけRegionを指定する
    if(!isInitializedMapRegion) {
        MKCoordinateRegion region = mapView_.region;
        region.center = newLocation.coordinate;
        region.span.latitudeDelta = 0.01;
        region.span.longitudeDelta = 0.01;
        [mapView_ setRegion:region];
        
        isInitializedMapRegion = true;
    }
    //[locationManager stopUpdatingLocation]; // 位置情報の更新の停止
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [locationManager stopUpdatingLocation];
}

- (void)viewDidUnload
{
    [self setMapView_:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma --
# pragma Camera
// アクション
- (IBAction)showCameraSheet:(id)sender
{
    // アクションシートを作る
    UIActionSheet*  sheet;
    sheet = [[UIActionSheet alloc]
             initWithTitle:@"Select Soruce Type"
             delegate:self
             cancelButtonTitle:@"Cancel"
             destructiveButtonTitle:nil
             otherButtonTitles:@"Camera", @"Photo Library", nil];
    
    // アクションシートを表示する
    [sheet showInView:self.view];
}

- (IBAction)createMap:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Map Title" message:@" ¥n " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    textField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
    textField.backgroundColor = [UIColor whiteColor];
    [alert addSubview:textField];
    
    [alert show];
    [textField becomeFirstResponder];
}

- (IBAction)tapOnMap:(id)sender {
    //マップをシングルタップした時の処理
    CGPoint tapPoint = [(UITapGestureRecognizer*)sender locationInView:mapView_];
    coordinateWithTap = [mapView_ convertPoint:tapPoint toCoordinateFromView:mapView_];
    [self drawCircle];
    isPinWithTap = true;
    [self showCameraSheet:nil];
    
    /*
    UIAlertView* alert =[[UIAlertView alloc] initWithTitle:@"pin" message:@"Do you want to pin?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert setTag:1];
    [alert show];
     */
    
}

- (IBAction)cancelCreating:(id)sender {
    self.mmEntity = nil;
    [delegate createdMap:self];
}

- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alert result tag:%d index:%d",alertView.tag,buttonIndex);
    if (buttonIndex == 1) {
        switch (alertView.tag) {
            case 0: //MapTitle
                mmEntity.title = textField.text;
                [delegate createdMap:self];
                break;
            case 1: //Pin picture
                isPinWithTap = true;
                [self showCameraSheet:nil];
                break;
            default:
                break;
        }
        
    }
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // ボタンインデックスをチェックする
    if (buttonIndex >= 3) {
        return;
    }
    
    // ソースタイプを決定する
    UIImagePickerControllerSourceType   sourceType = 0;
    switch (buttonIndex) {
        case 0: {
            sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        }
        case 1: {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        }
        default: {
            isPinWithTap = false;
            return;
        }
    }
    
    // 使用可能かどうかチェックする
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        return;
    }
    
    // イメージピッカーを作る
    UIImagePickerController*    imagePicker = [CreateMapViewController defaultPicker];
    imagePicker.sourceType = sourceType;
    //imagePicker.allowsImageEditing = YES;
    imagePicker.delegate = self;
    
    // イメージピッカーを表示する
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController*)picker
        didFinishPickingImage:(UIImage*)image
                  editingInfo:(NSDictionary*)editingInfo
{
    // イメージピッカーを隠す
    [self dismissModalViewControllerAnimated:YES];
    
    //TODO: save Photo and annotate to Map
    annotNumber++;
    CLLocationCoordinate2D coordinate;
    if(isPinWithTap) {
        coordinate = coordinateWithTap;
        isPinWithTap = false;
    }else {
        coordinate = mapView_.userLocation.coordinate; //ユーザ現在位置の経緯度
    }
    double lat = coordinate.latitude;
    double lng = coordinate.longitude;
    
    NSString* uriString = [NSString stringWithFormat:@"%d_%d.jpg",mapNumber,annotNumber];
    MapAnnotationEntity* annot = [[MapAnnotationEntity alloc] initWithData:0 mapNo:mapNumber
                                                                       lat:lat lng:lng
                                                                       uri:uriString];
    //TODO: 多分画像の保存処理が重い
    
    Database* db = [Database getInstance];
    
    if([db insertAnnotation:annot]) {
        NSLog(@"take photo, lat:%f, lng:%f, uri:%@",lat,lng,uriString);
        [FileIO data2file:uriString subDir:@"mapImage" data:UIImageJPEGRepresentation(image, 0.9)];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    //撮影場所にピンを立てる
    newAnnot = annot;
    [self annotatePhoto:newAnnot];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    // イメージピッカーを隠す
    [self dismissModalViewControllerAnimated:YES];
}

#pragma --
#pragma Annotation処理
//ピンが落ちてくる処理。    [_mapView addAnnotation:annotation]が呼ばれると、このメソッドが自動的に呼ばれ、上からピンが落ちてくるアニメーションになる。
-(MKAnnotationView*)mapView:(MKMapView*) mapView viewForAnnotation:(id )annotation
{
    if (![annotation isKindOfClass:[ImageAnnotation class]]
        && annotation == mapView.userLocation) {
        NSLog(@"are");
        return nil;
    }
    
    MKPinAnnotationView *annotationView;
    
    NSString* identifier = [NSString stringWithFormat:@"Pin_%d",newAnnot.id_];
    
    annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(nil == annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }

    NSLog(@"file:%@",newAnnot.imageUri);
    if([FileIO existsFile:newAnnot.imageUri subDir:@"mapImage"]) {
        NSLog(@"file exists.");
    }
    
    //annotationView.image = [UIImage imageWithData:[FileIO file2data:newAnnot.imageUri subDir:@"mapImage"]];
    //if(annotationView.image == nil) {
    //    NSLog(@"image not found");
    //}
    annotationView.animatesDrop = YES; //このプロパティでアニメーションドロップを設定
    annotationView.canShowCallout = YES; //このプロパティを設定してコールアウト（文字を表示する吹出し）を表示
    annotationView.annotation = annotation; //このメソッドで設定したアノテーションをannotationViewに再追加してreturnで返す
    return annotationView;
}

- (MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView* view = [[MKCircleView alloc] initWithOverlay:overlay];
        view.strokeColor = [UIColor redColor];
        view.lineWidth = 5.0;
        return view;
    }else {
        if(baseLinesView != nil) {
            [mapView_ removeOverlay:baseLinesView.overlay];
        }
        baseLinesView = [[MKPolylineView alloc] initWithOverlay:overlay];
        MKPolylineView* view = baseLinesView;
        view.strokeColor = [UIColor blueColor];
        view.lineWidth = 5.0;
        return view;
    }
    
}

- (void)annotatePhoto:(MapAnnotationEntity*)annotEntity
{
    // アノテーションを作成する
    ImageAnnotation*  annotation;
    annotation = [[ImageAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(annotEntity.latitude, annotEntity.longitude)];
    annotation.title = annotEntity.imageUri;
    
    //annotation.animatesDrop = YES;
    [annotEntityList addObject:annotEntity];
    // アノテーションを追加する
    [mapView_ addAnnotation:annotation];
    [self drawLines];
}

#pragma mark -
#pragma mark - 描画

- (void) drawCircle{
    MKCircle* circle = [MKCircle circleWithCenterCoordinate:coordinateWithTap radius:5];
    [mapView_ addOverlay:circle];
}

- (void) drawLines {
    int count = annotEntityList.count;
    CLLocationCoordinate2D coords[count];
    
    for (int i=0;i<count;i++) {
        MapAnnotationEntity* entity = [annotEntityList objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(entity.latitude, entity.longitude);
    }
    
    MKPolyline* line = [MKPolyline polylineWithCoordinates:coords count:count];
    [mapView_ addOverlay:line];
}

@end
