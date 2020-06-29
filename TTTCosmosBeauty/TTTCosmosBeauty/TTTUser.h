//
//  TTTUser.h
//  TTTCosmosBeauty
//

#import <Foundation/Foundation.h>

@interface TTTUser : NSObject
@property (nonatomic, assign) int64_t uid;
@property (nonatomic, assign) BOOL mutedSelf; //是否静音

- (instancetype)initWith:(int64_t)uid;
@end
