//
//  FileIO.m
//  iPadTest_100326
//
//  Created by 高橋 勲 on 10/04/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileIO.h"
//#import "UserSettingUtil.h"

static NSString *dirName = @"navi";

@implementation FileIO

- (id) init
{
    if(self = [super init])
    {
    }
    
    return self;
}

//文字列型からデータ型への変換メソッド
+ (NSData*)str2data:(NSString*)str {
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

//データ型から文字列型への変換メソッド
+ (NSString*)data2str:(NSData*)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

//半角の一部記号を全角に変換するメソッド
+ (NSString*)changeSymbolToFull:(NSString*)str
{
    NSString* string = [NSString stringWithString:str];
    
    //string = [string stringByReplacingOccurrencesOfString:@" " withString:@"　"];
    string = [string stringByReplacingOccurrencesOfString:@":" withString:@"："];
    string = [string stringByReplacingOccurrencesOfString:@"+" withString:@"＋"];
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@"＜"];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@"＞"];
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"＆"];
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"”"];
    
    return string;
}
//全角の一部記号を半角に変換するメソッド
+ (NSString*)changeSymbolToHalf:(NSString*)str;
{
    NSString* string = [NSString stringWithString:str];
    
    //string = [string stringByReplacingOccurrencesOfString:@"　" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"：" withString:@":"];
    string = [string stringByReplacingOccurrencesOfString:@"＋" withString:@"+"];
    string = [string stringByReplacingOccurrencesOfString:@"＜" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"＞" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"＆" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
    
    return string;
}

//文字列の行数(\n区切り)を返すメソッド
+ (int)lineCountWithN:(NSString*)string
{
    int line = 1;
    NSString* str = [NSString stringWithString:string];
    NSRange range;
    
    while(str.length > 0)
    {
        range = [str rangeOfString:@"\n"];
        if(range.location == NSNotFound)
        {
            break;
        }
        else
        {
            line++;
            str = [str substringFromIndex:range.location+1];
        }
        
    }
    
    return line;
}


//文字列の面積を求める
+ (CGSize) calculateStringArea:(int)fontSize text:(NSString*)text{
	//TMBとの計算の誤差を埋める値（適当）
	float heightRelativeity = 1.3;
	float widthRelativeity = 1.3;
	
	float width = 0.0f;
	float height = 0.0f;
	NSArray* texts = [text componentsSeparatedByString:@"\n"];
	int textNum = [texts count];
	for(int i = 0; i < textNum;  i++){
		NSString *str = [texts objectAtIndex:i];
		NSLog(@"str:%@",str);
		CGSize size = [[texts objectAtIndex:i] sizeWithFont:[UIFont fontWithName:@"HiraKakuProN-W6" size:fontSize]];
		height += size.height;
		if (width < size.width) {
			width = size.width;
		}
		
		
    }
	NSLog(@"calculateStringArea %@ width = %f height = %f",text,width*widthRelativeity, height*heightRelativeity);
	return CGSizeMake(width*widthRelativeity+50,height*heightRelativeity+20);
	//	NSLog(@"calculateStringArea %s width = %f height = %f",_text,width, height);
	//	return CGSizeMake(width,height+50);
}


//領域に合わせて適したフォントサイズを返すメソッド
+ (int)fontSizeToFitRegion:(int)firstSize name:(NSString*)fontName string:(NSString*)string region:(CGRect)region
{
    //初期サイズが0未満なら1を返す
    if(firstSize < 0 || [string isEqualToString:@""])
    {
        return 1;
    }
    
    int    fontSize    = firstSize;
    //初期サイズが0ならば、こちらで初期値を設定する
    if(fontSize == 0)
    {
        fontSize = 100;
    }
    
   // int line = [self lineCountWithN:string];
    
    //フォント作成
    UIFont*    font        = [UIFont fontWithName:@"HiraKakuProN-W6" size:fontSize];
    
    /*
    //高さに合わせて調節
    while(font.leading*line > region.size.height) 
    {
        fontSize--;
        font = [UIFont fontWithName:@"HiraKakuProN-W6" size:fontSize];
    }*/
    
    //幅に合わせて調節
    NSArray*    array = [string componentsSeparatedByString:@"\n"];
   
	//高さに合わせて調節
//    for(int i=0;i<[array count];i++)
//    {
//        NSString* temp = [array objectAtIndex:i];
//        //height += [temp sizeWithFont:font];
//        while([temp sizeWithFont:font].height > (region.size.height/line))
//        {
//            fontSize -= 1;
//            font = [UIFont fontWithName:@"HiraKakuProN-W6" size:fontSize];
//        }
//    }
	
	//各行のテキスト幅が領域の幅を超えないようにサイズ調節
    for(int i=0;i<[array count];i++)
    {
        NSString* temp = [array objectAtIndex:i];
        while([temp sizeWithFont:font].width > region.size.width)
        {
            fontSize -= 1;
            font = [UIFont fontWithName:@"HiraKakuProN-W6" size:fontSize];
            
        }
    }
	
	
    
       
    return fontSize;
}


//ファイルが存在するか
+ (BOOL)existsFile:(NSString*)path subDir:(NSString*)subDir{
    NSArray* paths=NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory,NSUserDomainMask,YES); 
    NSString* dir=[paths objectAtIndex:0]; 
    NSString* userDir = [dir stringByAppendingPathComponent:dirName];
    if(subDir)
    {
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    path=[userDir stringByAppendingPathComponent:path]; 
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

//ディレクトリの生成メソッド(既にディレクトリが存在するなら何もしない)
+ (void)makeDir:(NSString*)path subDir:(NSString*)subDir{
    if ([FileIO existsFile:path subDir:subDir]) return;
    
    NSArray* paths=NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory,NSUserDomainMask,YES); 
    NSString* dir=[paths objectAtIndex:0]; 
    path=[dir stringByAppendingPathComponent:path];
    if(subDir)
    {
        path = [path stringByAppendingPathComponent:subDir];
    }
//    [[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];  <-Deprecated
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
}

//ファイルの削除
+ (void)removeFile:(NSString*)path subDir:(NSString*)subDir{
    if (![FileIO existsFile:path subDir:subDir]) return;

    NSArray* paths=NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory,NSUserDomainMask,YES); 
    NSString* dir=[paths objectAtIndex:0];
    NSString* userDir = [dir stringByAppendingPathComponent:dirName];
    if(subDir)
    {
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    path=[userDir stringByAppendingPathComponent:path]; 
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

//データ型の内容をファイルへ書き込むメソッド
+ (BOOL)data2file:(NSString*)fileName subDir:(NSString*)subDir data:(NSData*)data {
   
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dir = [path objectAtIndex:0];
    NSString* userDir = [dir stringByAppendingPathComponent:dirName];
    if(subDir)
    {
        [self makeDir:dirName subDir:subDir];
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    NSString* file = [userDir stringByAppendingPathComponent:fileName];
    return ([data writeToFile:file atomically:YES]);
}

// 指定したディレクトリ内のファイルパスの一覧を返す
+ (NSArray*) getFileList:(NSString*)dirName
{
    NSString* dirPath = [FileIO getPath:dirName subDir:nil];
    
    return  [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
}

//適切なファイル名を返す
+ (NSString *)getPath:(NSString *)fileName subDir:(NSString *)subDir{
 
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dir = [path objectAtIndex:0];
    NSString* userDir = [dir stringByAppendingPathComponent:dirName];
    if(subDir)
    {
        [self makeDir:dirName subDir:subDir];
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    NSString* file = [userDir stringByAppendingPathComponent:fileName];
    return file;
}

//ファイルから読み込み、その内容をデータ型で返すメソッド
+ (NSData*)file2data:(NSString*)fileName subDir:(NSString*)subDir{

    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dir = [path objectAtIndex:0];
    NSString* userDir = [dir stringByAppendingPathComponent:dirName];
    if(subDir != nil)
    {
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    NSString* file = [userDir stringByAppendingPathComponent:fileName];
    return [[NSData alloc] initWithContentsOfFile:file];
}

//配列をアーカイブするメソッド
+(void) archiveArray:(NSMutableArray*)array fileName:(NSString*)fileName subDir:(NSString*)subDir
{
    
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dir = [path objectAtIndex:0];
    NSString* userDir = [dir stringByAppendingPathComponent:dirName];
    if(subDir != nil)
    {
        [self makeDir:dirName subDir:subDir];
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    NSString* filePath = [userDir stringByAppendingPathComponent:fileName];
    
    [NSKeyedArchiver archiveRootObject:array toFile:filePath];
}

//アーカイブから配列を読み出すメソッド
+(NSMutableArray*) arrayFromArchive:(NSString*)fileName subDir:(NSString*)subDir
{

    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dir = [path objectAtIndex:0];
    NSString* userDir = [dir stringByAppendingPathComponent:dirName];
    if(subDir != nil)
    {
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    NSString* filePath = [userDir stringByAppendingPathComponent:fileName];
    
    NSMutableArray* array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    return array;
}

@end
