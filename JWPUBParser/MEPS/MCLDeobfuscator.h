//
//  MCLDeobfuscator.h
//  MEPSCommon
//
//  Created on 5/23/17.
//  Copyright © 2017 Watch Tower Bible and Tract Society of Pennsylvania, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCLDeobfuscator : NSObject

/**
 * Init the deobfuscator with the given key.
 * @param key NSString representing the decryption key.
 */
- (instancetype)initWithKey:(NSString *)key;

/**
 * Deobfuscate the specified protected data.
 * @param protectedData NSData which is assumed to be obfuscated through encryption and deflation.
 * @return A NSData instance representing the deobfuscated data, or nil if deobfuscating did not work.
 */
- (NSData *)apply:(NSData *)protectedData;

@end
