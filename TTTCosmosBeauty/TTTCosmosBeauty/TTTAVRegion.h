//
//  TTTAVRegion.h
//  TTTCosmosBeauty
//

#import <UIKit/UIKit.h>

@interface TTTAVRegion : UIView

@property (nonatomic, strong) TTTUser *user;

- (void)configureRegion:(TTTUser *)user;
- (void)closeRegion;
- (void)reportAudioLevel:(NSUInteger)level;
- (void)setRemoterAudioStats:(NSUInteger)stats;
- (void)setRemoterVideoStats:(NSUInteger)stats;
- (void)mutedSelf:(BOOL)mute;

@end
