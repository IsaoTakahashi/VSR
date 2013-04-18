//
//  MapAnnotationEntity.h
//  Realation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapAnnotationEntity : NSObject {
    int id_;
    int mapNo;
    double latitude;
    double longitude;
    NSString* imageUri;
}
@property (nonatomic, assign) int id_;
@property (nonatomic, assign) int mapNo;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (strong, nonatomic) NSString *imageUri;

- (id) init;
- (id) initWithData:(int)idNum mapNo:(int)mapNumber lat:(double)lat lng:(double)lng uri:(NSString*)uri;

@end
