//
//  NSString+Additions.h
//  BlogDemo
//
//  Created by 孟令通 on 2018/3/8.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

+ (BOOL)regularForTel:(NSString *)tel;
+ (BOOL)regularForPsw:(NSString *)psw;
+ (BOOL)regulatForBankCardNumber:(NSString *)cardNumber;

@end
