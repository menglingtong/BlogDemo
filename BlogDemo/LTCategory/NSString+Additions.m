//
//  NSString+Additions.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/3/8.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (BOOL)regularForTel:(NSString *)tel
{
    NSString *pattern = @"^1+[3578]+\\d{9}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [predicate evaluateWithObject:tel];
}

+ (BOOL)regularForPsw:(NSString *)psw
{
    NSString *pattern = @"^[0-9a-zA-Z]{6,}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [predicate evaluateWithObject:psw];
}

+ (BOOL)regulatForBankCardNumber:(NSString *)cardNumber
{
    NSString *pattern = @"^[0-9]{16,21}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [predicate evaluateWithObject:cardNumber];
}

@end
