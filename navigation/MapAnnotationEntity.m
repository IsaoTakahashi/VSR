//
//  MapAnnotationEntity.m
//  Realation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "MapAnnotationEntity.h"

@implementation MapAnnotationEntity

@synthesize id_;
@synthesize mapNo;
@synthesize latitude;
@synthesize longitude;
@synthesize imageUri;

- (id) init {
    if(self = [super init]) {
        id_ = 0;
        mapNo = 0;
        latitude = 0.0f;
        longitude = 0.0f;
        imageUri = nil;
    }
    return self;
}

- (id) initWithData:(int)idNum mapNo:(int)mapNumber lat:(double)lat lng:(double)lng uri:(NSString*)uri {
    if (self = [self init]) {
        self.id_ = idNum;
        self.mapNo = mapNumber;
        self.latitude = lat;
        self.longitude = lng;
        self.imageUri = uri;
    }
    return self;
}

@end
