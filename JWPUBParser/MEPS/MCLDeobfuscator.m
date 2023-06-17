//
//  MCLDeobfuscator.m
//  MEPSCommon
//
//  Created on 5/23/17.
//  Copyright © 2017 Watch Tower Bible and Tract Society of Pennsylvania, Inc. All rights reserved.
//

#import "MCLDeobfuscator.h"
#import <CommonCrypto/CommonCrypto.h>
#import <zlib.h>

@implementation MCLDeobfuscator
{
    unsigned char _key[kCCKeySizeAES128];
    unsigned char _iv[kCCKeySizeAES128];
}

- (instancetype)initWithKey:(NSString *)key
{
    if (self = [super init])
    {
        char dummy[] = { 17, -53, -75, 88, 126, 50, -124, 109, 76, 38, 121, 12,
            99, 61, -94, -119, -10, 111, -27, -124, 42, 58, 88, 92, -31, -68,
            58, 41, 74, -11, -83, -89 };
        
        // Generate the base SHA256 hash
        unsigned char temp[CC_SHA256_DIGEST_LENGTH];
        size_t tempLength = CC_SHA256_DIGEST_LENGTH;
        const char *keyUTF8 = key.UTF8String;
        CC_SHA256(keyUTF8, (CC_LONG)strlen(keyUTF8), temp);
        
        // Prepare key and iv
        for (NSInteger i = 0; i < tempLength / 2; i++)
        {
            _key[i] = dummy[i] ^ temp[i];
            _iv[i] = dummy[i + tempLength / 2] ^ temp[i + tempLength / 2];
        }
    }
    
    return self;
}

- (NSData *)apply:(NSData *)protectedData
{
    NSData *decryptedData = [self decryptWithData:protectedData];
    
    
    if (decryptedData) {
        return [self inflateWithData:decryptedData];
    }
    
    return nil;
}

- (NSData *)inflateWithData:(NSData *)data
{
    z_stream zs;
    memset(&zs, 0, sizeof(zs));
    
    if (inflateInit(&zs) != Z_OK) {
        return nil;
    }
    
    zs.next_in = (Bytef *)data.bytes;
    zs.avail_in = (unsigned int)data.length;
    
    int ret;
    char outbuffer[32768];
    NSMutableData *out = [NSMutableData data];
    
    do {
        zs.next_out = (Bytef *)outbuffer;
        zs.avail_out = sizeof(outbuffer);
        
        ret = inflate(&zs, 0);
        
        if (out.length < zs.total_out) {
            [out appendBytes:outbuffer length:zs.total_out - out.length];
        }
        
    } while (ret == Z_OK);
    
    
    inflateEnd(&zs);
    
    if (ret != Z_STREAM_END) {
        return nil;
    }
    
    return out;
}

- (NSData *)decryptWithData:(NSData *)data
{
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numOfBytesDecrypted = 0;
    CCCryptorStatus status = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding,
                                     _key, kCCKeySizeAES128,
                                     _iv,
                                     data.bytes,
                                     data.length,
                                     buffer,
                                     bufferSize,
                                     &numOfBytesDecrypted);
    
    if (status == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numOfBytesDecrypted];
    }
    
    free(buffer);
    
    return nil;
}

@end
