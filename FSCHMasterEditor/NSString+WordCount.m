//
//  NSString+WordCount.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/24/22.
//

#import "NSString+WordCount.h"

@implementation NSString (NSString_WordCount)

- (NSUInteger)wordCount {
    NSCharacterSet *separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *words = [self componentsSeparatedByCharactersInSet:separators];

    NSIndexSet *separatorIndexes = [words indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqualToString:@""];
    }];

    return [words count] - [separatorIndexes count];
}


@end
