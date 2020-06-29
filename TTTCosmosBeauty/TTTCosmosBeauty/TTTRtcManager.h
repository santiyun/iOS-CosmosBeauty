//
//  TTTRtcManager.h
//  TTTCosmosBeauty
//

#import <Foundation/Foundation.h>
#import <TTTRtcEngineKit/TTTRtcEngineKit.h>
#import "TTTUser.h"

@interface TTTRtcManager : NSObject
@property (nonatomic, strong) TTTRtcEngineKit *rtcEngine;
@property (nonatomic, strong) TTTUser *me;
@property (nonatomic, assign) int64_t roomID;
//settings
@property (nonatomic, assign) BOOL isHighQualityAudio;
@property (nonatomic, assign) TTTRtcVideoProfile videoProfile;//set default is 360P

+ (instancetype)manager;
@end
