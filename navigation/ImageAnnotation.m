//
//  ImageAnnotation.m
//  Realation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "ImageAnnotation.h"

@implementation ImageAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id) initWithCoordinate:(CLLocationCoordinate2D)c {
    if (self = [super init]) {
        title = @"";
        subtitle = @"";
        coordinate = c;
    }
    return self;
}

@end
