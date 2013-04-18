//
//  FileIO.h
//  iPadTest_100326
//
//  Created by 高橋 勲 on 10/04/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//File出力に関係するクラス(10/04/15時点では死にクラス)

@interface FileIO : NSObject {

}

//文字列型からデータ型への変換メソッド
+ (NSData*)str2data:(NSString*)str;
//データ型から文字列型への変換メソッド
+ (NSString*)data2str:(NSData*)data;
//半角の一部記号を全角に変換するメソッド
+ (NSString*)changeSymbolToFull:(NSString*)str;
//全角の一部記号を半角に変換するメソッド
+ (NSString*)changeSymbolToHalf:(NSString*)str;
//文字列の行数(\n区切り)を返すメソッド
+ (int)lineCountWithN:(NSString*)string;
//文字列の面積を求める
+ (CGSize) calculateStringArea:(int)fontSize text:(NSString*)texts;
//領域に合わせて適したフォントサイズを返すメソッド
+ (int)fontSizeToFitRegion:(int)firstSize name:(NSString*)fontName string:(NSString*)string region:(CGRect)region;


// 指定したディレクトリ内のファイルパスの一覧を返す
+ (NSArray*) getFileList:(NSString*)dirName;
//適切なファイル名を返す
+ (NSString *)getPath:(NSString *)fileName subDir:(NSString *)subDir;
//ファイルが存在するか
+ (BOOL)existsFile:(NSString*)path subDir:(NSString*)subDir;
//ディレクトリの生成メソッド(既にディレクトリが存在するなら何もしない)
+ (void)makeDir:(NSString*)path subDir:(NSString*)subDir;
//ファイルの削除
+ (void)removeFile:(NSString*)path subDir:(NSString*)subDir;
//データ型の内容をファイルへ書き込むメソッド
+ (BOOL)data2file:(NSString*)fileName subDir:(NSString*)subDir data:(NSData*)data;
//ファイルから読み込み、その内容をデータ型で返すメソッド
+ (NSData*)file2data:(NSString*)fileName subDir:(NSString*)subDir;

//配列をアーカイブするメソッド
+(void) archiveArray:(NSMutableArray*)array fileName:(NSString*)fileName subDir:(NSString*)subDir;
//アーカイブから配列を読み出すメソッド
+(NSMutableArray*) arrayFromArchive:(NSString*)fileName subDir:(NSString*)subDir;

@end
