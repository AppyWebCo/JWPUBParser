//
//  JWPDeobfuscator.h
//
//

#import <Foundation/Foundation.h>

@interface JWPDeobfuscator : NSObject

- (instancetype)initWithKey:(NSString *)key;

- (NSData *)apply:(NSData *)protectedData;

@end
