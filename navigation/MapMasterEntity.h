//
//  MapMasterEntity.h
//  Realation
//
//  Created by 高橋 勲 on 2012/10/15.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapMasterEntity : NSObject {
    int mapNo;
    NSString* title;
    NSString* depName;
    NSString* destName;
}

@property (nonatomic, assign) int mapNo;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* depName;
@property (strong, nonatomic) NSString* destName;

@end
