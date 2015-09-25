//
//  ArthurHexOperation.m
//  libCodoonBLE
//
//  Created by lichen on 5/16/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurHexOperation.h"

@implementation ArthurHexOperation

+(NSData *)hexToNSData:(NSString *)strHex
{
//    TODO: 检测字符是否超过了十六进制
    NSString *strComposedHex = [strHex stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [strComposedHex length]/2; i++) {
        byte_chars[0] = [strComposedHex characterAtIndex:i*2];
        byte_chars[1] = [strComposedHex characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1]; 
    }
    
    return [NSData dataWithData:commandToSend];
}

+(BOOL)data:(NSData *)data beginWithHex:(NSString *)strHex
{
    NSData *dataBegin = [ArthurHexOperation hexToNSData:strHex];
    NSUInteger uLength = [dataBegin length];
    NSData *dataSub = [data subdataWithRange:NSMakeRange(0, uLength)];
    return [dataSub isEqualToData:dataBegin];
}

+(NSString *)NSDataToHexString:(NSData *)data
{
    NSString *str = @"";
    Byte *dataBytes = (Byte*)[data bytes];
    for (int nIndex = 0; nIndex < [data length]; nIndex++) {
        Byte byte = dataBytes[nIndex];
        NSString *strAppend = [NSString stringWithFormat:@"%2x ", byte];
        str = [str stringByAppendingString:strAppend];
    }
    return str;
}

@end
