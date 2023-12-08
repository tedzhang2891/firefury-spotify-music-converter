//
//  VersionComparator.m
//  DecryptCore
//
//  Created by ted zhang on 8/22/18.
//  Copyright © 2018 ted zhang. All rights reserved.
//

#import "VersionComparator.h"

VersionComparator* defaultComparator = nil;

@implementation VersionComparator

+ (id)defaultComparator { 
    if (defaultComparator == nil) {
        defaultComparator = [[VersionComparator alloc] init];
    }
    return defaultComparator;
}

- (long long)compareVersion:(NSString *)bundle_ver toVersion:(NSString *)special_ver {
    long long retValue = 0;
    NSArray* bundle_version = [self splitVersionString:bundle_ver];
    NSArray* special_version = [self splitVersionString:special_ver];
    NSUInteger bundle_ver_cnt = [bundle_version count];
    NSUInteger special_ver_cnt = [special_version count];
    if (bundle_ver_cnt < special_ver_cnt) {
        special_ver_cnt = bundle_ver_cnt;
    }
    
    NSUInteger index = 0;
    while (index < special_ver_cnt) {
        NSString* szBundleVer = [bundle_version objectAtIndex:index];
        NSString* szSpecialVer = [special_version objectAtIndex:index];
        int typeBundleVer = [self typeOfCharacter:szBundleVer];
        int typeSpecialVer = [self typeOfCharacter:szSpecialVer];
        
        if (typeBundleVer != typeSpecialVer) {
            break;
        }
        
        if (typeBundleVer == 1) {
            if ([szBundleVer compare:szSpecialVer]) {
                return 1;
            }
        } else if (!typeBundleVer) {
            long long numBundleVer = [szBundleVer longLongValue];
            long long numSpecialVer = [szSpecialVer longLongValue];
            if (numBundleVer > numSpecialVer) {
                return 1;
            }
            if (numBundleVer < numSpecialVer) {
                return 0;
            }
        }
        
        if (typeBundleVer != 1 && typeSpecialVer != 1) {
            return 1;
        }
        
        if (typeBundleVer != 1 || typeSpecialVer == 1) {
            retValue = 1;
        }
        
        index ++;
    }
    
    if (bundle_ver_cnt == special_ver_cnt) {
        retValue = 1;
    } else {
        NSString* character = nil;
        long long tmpValue = 0;
        if (bundle_ver_cnt < special_ver_cnt){
            character = [special_version objectAtIndex:special_ver_cnt];
            tmpValue = -1;
            retValue = 1;
        } else {
            character = [bundle_version objectAtIndex:bundle_ver_cnt];
            tmpValue = 1;
            retValue = -1;
        }
        if ([self typeOfCharacter:character] != 1) {
            retValue = tmpValue;
        }
    }
    
    return retValue;
}

- (id)splitVersionString:(NSString *)version { 
    NSMutableArray* verArray = [NSMutableArray array];
    NSUInteger verLen = [version length];
    if (verLen) {
        NSString* subVer = [version substringFromIndex:1];
        NSMutableString* mSubVer = [subVer mutableCopy];
        int type = [self typeOfCharacter:subVer];
        NSUInteger index = 1;
        while (index < verLen) {
            NSString* subString = [version substringWithRange:NSMakeRange(index, 1)];
            int tmpType = [self typeOfCharacter:subString];
            if (type == 2 || type != tmpType) {
                NSString* typeString = [[NSString alloc] initWithString:mSubVer];
                [verArray addObject:typeString];
                [mSubVer setString:subString];
            } else {
                [mSubVer appendString:subString];
            }
            index ++;
        }
        NSString* subVerString = [NSString stringWithString:subVer];
        [verArray addObject:subVerString];
    }
    return verArray;
}

- (int)typeOfCharacter:(NSString *)special_char { 
    int type = 2;
    if (![special_char isEqualToString:@"."]) {
        type = 0;
        NSCharacterSet* decimalSet = [NSCharacterSet decimalDigitCharacterSet];
        unichar utf16char = [special_char characterAtIndex:0];
        if (![decimalSet characterIsMember:utf16char]) {
            type = 2;
            NSCharacterSet* whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
            if (![whitespaceSet characterIsMember:utf16char]) {
                NSCharacterSet* punctuationSet = [NSCharacterSet punctuationCharacterSet];
                if (![punctuationSet characterIsMember:utf16char]) {
                    type = 1;
                } else {
                    type = 2;
                }
            }
        }
    }
    return type;
}

@end
