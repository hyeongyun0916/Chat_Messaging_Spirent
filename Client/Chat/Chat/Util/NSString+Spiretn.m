//
//  NSString+Spiretn.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 21..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import "NSString+Spiretn.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (Spiretn)

- (BOOL)isValidPassword {
    NSString *stricterFilterString = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{10,}";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [passwordTest evaluateWithObject:self];
}

- (BOOL)IsValidEmail {
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [emailTest evaluateWithObject:self];
}

- (NSString *)AES128Encrypt {
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString* keyStr = @"abcdefghijk!@#!!";
    NSString* ivStr = @"nmlkjihgfedcba%!";
    NSData *keyData = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [ivStr dataUsingEncoding:NSUTF8StringEncoding];
    
    // 'key' should be 16 bytes for AES128, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    // fetch key data
    [keyData getBytes:keyPtr];
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    
    char ivPtr[16];
    [ivData getBytes:ivPtr];
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          ivPtr, /* initialization vector (optional) */
                                          [data bytes],
                                          dataLength, /* input */
                                          buffer,
                                          bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [self NSDataToHex:[NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted]];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

static inline char itoh(int i) {
    if (i > 9) return 'A' + (i - 10);
    return '0' + i;
}

- (NSString *)NSDataToHex:(NSData*)data {
    NSUInteger i, len;
    unsigned char *buf, *bytes;
    
    len = data.length;
    bytes = (unsigned char*)data.bytes;
    buf = malloc(len*2);
    
    for (i=0; i<len; i++) {
        buf[i*2] = itoh((bytes[i] >> 4) & 0xF);
        buf[i*2+1] = itoh(bytes[i] & 0xF);
    }
    
    return [[NSString alloc] initWithBytesNoCopy:buf
                                          length:len*2
                                        encoding:NSASCIIStringEncoding
                                    freeWhenDone:YES];
}



@end
