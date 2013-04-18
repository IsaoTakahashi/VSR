//
//  Database.h
//  Realation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "MapAnnotationEntity.h"
#import "MapMasterEntity.h"

@interface Database : NSObject {
@protected
    FMDatabase *connection;
    NSMutableSet *cache;
}
@property (nonatomic, retain) FMDatabase *connection;
@property (nonatomic, retain) NSMutableSet *cache;
@property (nonatomic, assign) BOOL logging;

+ (Database *) getInstance;

- (id) init;
- (void)dealloc;

//DB周りのラッパ
- (void) connect:(NSString*)dbname;
- (void) disconnect;
- (BOOL) isConnected;
- (void) beginTransaction;
- (void) rollback;
- (void) commit;
- (BOOL) hadError;
- (BOOL) isTransactionStarted;
//SessionDB周り
- (NSString *) getDBFilePath:(NSString *) dbname;
- (NSString *) getOldDBFilePath:(NSString *) dbname;
- (void) createEditableCopyOfDatabaseIfNeeded:(NSString *)dbname;

//Insert/Update
- (Boolean) insertAnnotation:(MapAnnotationEntity*)annot;
- (Boolean) insertMapMaster:(MapMasterEntity*)mm;

//Select
- (NSMutableArray*)getMapList;
- (int) getMapListCount;
- (NSMutableArray*)getAnnotationListWithMapNo:(int)mapNumber;

- (MapMasterEntity*) getMapMasterWithID:(int)mapNo;
- (NSMutableArray*) getMapMasterList;

//Delete
- (void) deleteAllRecord;
- (void) deleteAnnotationWithMapNo:(int)mapNo;

//Create
- (Boolean) createMapMaster;

@end
