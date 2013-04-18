//
//  ImageAnnotation.h
//  Realation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ImageAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString* subtitle;
    NSString* title;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString* subtitle;
@property (nonatomic, retain) NSString* title;

- (id) initWithCoordinate:(CLLocationCoordinate2D) c;

@end
