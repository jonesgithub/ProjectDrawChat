//
//  ArthurHexOperation.h
//  libCodoonBLE
//
//  Created by lichen on 5/16/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArthurHexOperation : NSObject

//十六制字符串转成NSData
//一个byte之间可以有空格
//"1C 24" => 0x1C24
+(NSData *)hexToNSData:(NSString *)strHex;

//检测一个NSData是否以strHex开头
+(BOOL)data:(NSData *)data beginWithHex:(NSString *)strHex;

+(NSString *)NSDataToHexString:(NSData *)data;

@end
