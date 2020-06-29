//
//  TTTUser.m
//  TTTCosmosBeauty
//

#import "TTTUser.h"

@implementation TTTUser

- (instancetype)initWith:(int64_t)uid {
    self = [super init];
    if (self) {
        _uid = uid;
    }
    return self;
}

@end
