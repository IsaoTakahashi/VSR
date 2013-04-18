//
//  Database.m
//  Realation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "Database.h"
#import "FileIO.h"

//クラスプロパティの代わり
static Database* naviDatabase;

@implementation Database

@synthesize connection;
@synthesize cache;
static Boolean isInitialized = false;

//シングルトンメソッド（session.dbという名前で初期化）
+ (Database *) getInstance {
    if(naviDatabase == nil){
        naviDatabase = [[Database alloc] init];
        [naviDatabase connect: @"navi.db"];
        
        if(!isInitialized) {
            //[naviDatabase createMapMaster];
            isInitialized = true;
        }
        //naviDatabase.logging = YES;ß
    }
    return naviDatabase;
}

//コンストラクタ
- (id) init{
    self = [super init];
    self.connection = nil;
    self.cache = [[NSMutableSet alloc] init];
    return self;
}

//デストラクタ
- (void) dealloc{
    //[self disconnect];
    [self.cache removeAllObjects];
}

//接続
//ファイルが既にあるかどうかチェックして、なければsessionDBをセットアップする
- (void) connect:(NSString *)dbname{
    NSString* dbpath = [self getDBFilePath:dbname];
    
    [self createEditableCopyOfDatabaseIfNeeded: dbname];
    
    self.connection = [FMDatabase databaseWithPath:dbpath];
    
    [self.connection open];
    if([self hadError]){
        NSLog(@"Could not open Database.");
    }
    
    //[self updateDB];
}

//DBファイルへのパスを取得
- (NSString *) getDBFilePath:(NSString *) dbname{
    return [FileIO getPath: dbname subDir:@""];
}

//古いDBファイルへのパスを取得
- (NSString *) getOldDBFilePath:(NSString *) dbname{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:dbname];
}

//DBファイルを作成
- (void)createEditableCopyOfDatabaseIfNeeded:(NSString *)dbname {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    //古いデータベースをコピーする
    NSString *writableOldDBPath = [self getOldDBFilePath:dbname];
    NSString *writableDBPath = [self getDBFilePath:dbname];
    
    //NSString *debugDBPath = [self getDBFilePath:@"debug.sqlite"];
    //[fileManager copyItemAtPath:writableDBPath toPath:debugDBPath error:&error];
    //[fileManager copyItemAtPath:debugDBPath toPath:writableDBPath error:&error];
    //[fileManager removeItemAtPath:writableDBPath error:&error];
    
    //すでにファイルがあれば処理しない。
    if([FileIO existsFile:dbname subDir:@""]){
        return;
    }
    //昔の古いファイルがあれば消す
    if([fileManager isWritableFileAtPath: writableOldDBPath]){
        [fileManager removeItemAtPath:writableOldDBPath error:&error];
    }
    //デフォルトファイルをコピー
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbname];
    [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
}

//切断
- (void) disconnect{
    if([self isConnected]){
        [self.connection close];
    }
    self.connection = nil;
}

//接続されているかどうか
- (BOOL) isConnected{
    if(self.connection != nil){
        return YES;
    }
    return NO;
}

//トランザクションが開始されているかどうか
- (BOOL) isTransactionStarted{
    if([self isConnected] == NO){
        return NO;
    }
    return [self.connection inTransaction];
}

//トランザクション開始
- (void) beginTransaction{
    if([self isConnected]){
        [self.connection beginTransaction];
    }else{
        NSLog(@"Could not open Database.");
    }
}

//コミット
- (void) commit{
    if([self isConnected]){
        [self.connection commit];
    }else{
        NSLog(@"Could not open Database.");
    }
}

//ロールバック
- (void) rollback{
    if([self isConnected]){
        [self.connection rollback];
    }else{
        NSLog(@"Could not open Database.");
    }
}

//エラーチェック
- (BOOL) hadError{
    if(self.connection == nil){
        return true;
    }
    if ([self.connection hadError]) {
        NSLog(@"Err %d: %@", [self.connection lastErrorCode], [self.connection lastErrorMessage]);
        return true;
    }
    return false;
}

//ログをとるかどうかの設定を取得
- (BOOL) logging{
    return [self.connection traceExecution];
}

//ログをとるかどうかの設定
- (void) setLogging:(BOOL)logging{
    [self.connection setTraceExecution: logging];
}

#pragma --
#pragma Insert/Update
- (BOOL)executeUpdate1 {
    Database* _db = [Database getInstance];
    BOOL result = TRUE;
    //トランザクション開始(exclusive)
    [_db beginTransaction];
    
    //ステートメントの再利用フラグ
    //おそらくループ内で同一クエリの更新処理を行う場合バインドクエリの準備を何回
    //も実行してしまうのためこのフラグを設定する。
    //このフラグが設定されているとステートメントが再利用される。
    //[_db setShouldCacheStatements:YES];
    
    
    //insertクエリ実行(プリミティブ型は使えない)
    //    [_db executeUpdate:@"insert into example values (?, ?, ?, ?)",
    //                                1, 2, @"test", 4.1];
    // executeUpdateWithFormatメソッドで可能。
    
    for (int i=1; i<=30; i++) {
        [_db.connection executeUpdate:@"insert into example values (?, ?, ?, ?)",
         [NSNumber numberWithInt:i],
         [NSDate date],
         [NSString stringWithFormat:@"string : %d.", i],
         [NSNumber numberWithFloat:(float)i/3]];
        //check
        if ([_db hadError]) {
            result = FALSE;
            NSLog(@"Err %d: %@", [_db.connection lastErrorCode], [_db.connection lastErrorMessage]);
        }
    }
    
    //commit
    [_db commit];
    
    return result;
}

//Insert/Update
- (Boolean) insertAnnotation:(MapAnnotationEntity*)annot {
    Database* _db = [Database getInstance];
    
    [_db.connection executeUpdate:@"insert into map_annotation (map_no, latitude, longitude, image_uri) values (?,?,?,?)",
     [NSNumber numberWithInt:annot.mapNo],[NSNumber numberWithDouble:annot.latitude],[NSNumber numberWithDouble:annot.longitude],annot.imageUri
     ];
    
    if ([_db hadError]) {
        NSLog(@"Error occured at Insert Annotation");
        return false;
    }
    
    NSLog(@"Annotation has been inserted");
    return true;
}

- (Boolean) insertMapMaster:(MapMasterEntity*)mm {
    Database* _db = [Database getInstance];
    
    [_db.connection executeUpdate:@"insert into map_master (map_no, title, departure_name, destination_name) values(?,?,?,?)",
     [NSNumber numberWithInt:mm.mapNo],mm.title,mm.depName,mm.destName];
    
    if ([_db hadError]) {
        NSLog(@"Error occured at Insert MapMaster");
        return false;
    }
    
    NSLog(@"MapMaster hasbeen inserted");
    return true;
}

//Select
- (NSMutableArray*)getMapList {
    return nil;
}

- (int) getMapListCount {
    Database* _db = [Database getInstance];
    FMResultSet *rs = [_db.connection executeQuery:@"select count(*) cnt from map_master"];
    if([rs next]) {
        return [rs intForColumn:@"cnt"];
    }
    return -1;
}



- (NSMutableArray*)getAnnotationListWithMapNo:(int)mapNumber {
    NSMutableArray* list = [[NSMutableArray alloc] init];
    
    Database* _db = [Database getInstance];
    FMResultSet *rs = [_db.connection executeQuery:@"select * from map_annotation where map_no = ? order by id asc",[NSNumber numberWithInt:mapNumber]];
    
    while([rs next]) {
        MapAnnotationEntity* annot = [[MapAnnotationEntity alloc] initWithData:[rs intForColumn:@"id"]
                                                                         mapNo:[rs intForColumn:@"map_no"]
                                                                           lat:[rs doubleForColumn:@"latitude"]
                                                                           lng:[rs doubleForColumn:@"longitude"]
                                                                           uri:[rs stringForColumn:@"image_uri"]];
        
        [list addObject:annot];
    }
    
    [rs close];
    
    return list;
}

- (MapMasterEntity*) getMapMasterWithID:(int)mapNo {
    MapMasterEntity* mmEntity = nil;
    
    Database* _db = [Database getInstance];
    FMResultSet *rs = [_db.connection executeQuery:@"select * from map_master where map_no = ?",[NSNumber numberWithInt:mapNo]];
    if([rs next]) {
        mmEntity.mapNo = [rs intForColumn:@"map_no"];
        mmEntity.title = [rs stringForColumn:@"title"];
        mmEntity.depName = [rs stringForColumn:@"departure_name"];
        mmEntity.destName = [rs stringForColumn:@"destination_name"];
    }
    
    return mmEntity;
}

- (NSMutableArray*) getMapMasterList {
    NSMutableArray* list = [[NSMutableArray alloc] init];
    
    Database* _db = [Database getInstance];
    FMResultSet *rs = [_db.connection executeQuery:@"select * from map_master order by map_no"];
    
    while([rs next]) {
        MapMasterEntity* mmEntity = [[MapMasterEntity alloc] init];
        mmEntity.mapNo = [rs intForColumn:@"map_no"];
        mmEntity.title = [rs stringForColumn:@"title"];
        mmEntity.depName = [rs stringForColumn:@"departure_name"];
        mmEntity.destName = [rs stringForColumn:@"destination_name"];
        
        [list addObject:mmEntity];
    }
    
    [rs close];
    
    return list;
}

- (void) deleteAllRecord {
    Database* _db = [Database getInstance];
    [_db.connection executeUpdate:@"delete from map_master"];
    [_db.connection executeUpdate:@"delete from map_annotation"];
    
    [_db hadError];
}

- (void) deleteAnnotationWithMapNo:(int)mapNo {
    Database* _db = [Database getInstance];
    [_db.connection executeUpdate:@"delete from map_master where map_no = ?", [NSNumber numberWithInt:mapNo]];
    
    [_db hadError];
}

//Create
- (Boolean) createMapMaster {
    Database* _db = [Database getInstance];
    [_db.connection executeUpdate:@"CREATE TABLE MAP_MASTER(\
            MAP_NO INTEGER PRIMARY KEY NOT NULL,\
            TITLE TEXT NOT NULL,\
            DEPARTURE_NAME TEXT,\
            DESTINATION_NAME TEXT\
            )"];
    
    if([_db hadError]) {
        NSLog(@"failed creating MAP_MASTER");
        return false;
    }
    
    NSLog(@"MAP_MASTER has created!");
    return true;
}


@end
