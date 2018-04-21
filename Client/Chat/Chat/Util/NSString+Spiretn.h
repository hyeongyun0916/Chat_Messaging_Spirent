//
//  NSString+Spiretn.h
//  Chat
//
//  Created by 현균 문 on 2018. 4. 21..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Spiretn)

- (BOOL)isValidPassword;
- (BOOL)IsValidEmail;
- (NSString *)AES128Encrypt;
    
@end
