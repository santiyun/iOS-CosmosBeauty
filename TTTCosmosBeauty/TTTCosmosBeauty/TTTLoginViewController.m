//
//  TTTLoginViewController.m
//  TTTCosmosBeauty
//

#import "TTTLoginViewController.h"
#import <MMBeautyKit/CosmosBeautySDK.h>

@interface TTTLoginViewController () <TTTRtcEngineDelegate, CosmosBeautySDKDelegate>

@property (weak, nonatomic) IBOutlet UITextField *roomIDTF;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (nonatomic, assign) int64_t uid;

@end

@implementation TTTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *dateStr = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    _websiteLabel.text = [TTTRtcEngineKit.getSdkVersion stringByAppendingFormat:@"  %@", dateStr];
    _uid = arc4random() % 100000 + 1;
    int64_t roomID = [[NSUserDefaults standardUserDefaults] stringForKey:@"ENTERROOMID"].longLongValue;
    if (roomID == 0) {
        roomID = arc4random() % 1000000 + 1;
    }
    _roomIDTF.text = [NSString stringWithFormat:@"%lld", roomID];
}

- (IBAction)enterChannel:(id)sender {
    if (_roomIDTF.text.integerValue == 0 || _roomIDTF.text.length >= 19) {
        [self showToast:@"请输入大于0，19位以内的房间ID"];
        return;
    }
    
    [CosmosBeautySDK initSDKWithAppId:<#BeautySDK_AppId#> delegate:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - TTTRtcEngineDelegate
-(void)rtcEngine:(TTTRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(int64_t)uid elapsed:(NSInteger)elapsed {
    [TTProgressHud hideHud:self.view];
    [self performSegueWithIdentifier:@"VideoChat" sender:nil];
}

-(void)rtcEngine:(TTTRtcEngineKit *)engine didOccurError:(TTTRtcErrorCode)errorCode {
    NSString *errorInfo = @"";
    switch (errorCode) {
        case TTTRtc_Error_Enter_TimeOut:
            errorInfo = @"超时,10秒未收到服务器返回结果";
            break;
        case TTTRtc_Error_Enter_Failed:
            errorInfo = @"该直播间不存在";
            break;
        case TTTRtc_Error_Enter_BadVersion:
            errorInfo = @"版本错误";
            break;
        case TTTRtc_Error_InvalidChannelName:
            errorInfo = @"无效的房间名";
            break;
        default:
            errorInfo = [NSString stringWithFormat:@"未知错误：%zd",errorCode];
            break;
    }
    [TTProgressHud hideHud:self.view];
    [self showToast:errorInfo];
}

#pragma mark - CosmosBeautySDKDelegate

- (void)context:(CosmosBeautySDK *)context result:(BOOL)result detectorConfigFailedToLoad:(NSError * _Nullable)error {
    if (result) {
        [NSUserDefaults.standardUserDefaults setValue:_roomIDTF.text forKey:@"ENTERROOMID"];
        [NSUserDefaults.standardUserDefaults synchronize];
        TTTManager.me.uid = _uid;
        TTTManager.me.mutedSelf = NO;
        TTTManager.roomID = _roomIDTF.text.longLongValue;
        [TTProgressHud showHud:self.view];
        TTTRtcEngineKit *rtcEngine = TTTManager.rtcEngine;
        rtcEngine.delegate = self;
        [rtcEngine enableVideo];
        [rtcEngine muteLocalAudioStream:NO];
        [rtcEngine setChannelProfile:TTTRtc_ChannelProfile_Communication];
        [rtcEngine enableAudioVolumeIndication:1000 smooth:3];
        //settings
        if (TTTManager.isHighQualityAudio) {
            [rtcEngine setPreferAudioCodec:TTTRtc_AudioCodec_AAC bitrate:96 channels:1];
        }
        BOOL swapWH = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication.statusBarOrientation);
        [rtcEngine setVideoProfile:TTTManager.videoProfile swapWidthAndHeight:swapWH];
        [rtcEngine setBeautyFaceStatus:NO beautyLevel:0 brightLevel:0];
        [rtcEngine startPreview];
        [rtcEngine joinChannelByKey:nil channelName:_roomIDTF.text uid:_uid joinSuccess:nil];

    } else {
        [self showToast:error.localizedDescription];
    }
}

- (void)context:(CosmosBeautySDK *)context authorizationStatus:(MMBeautyKitAuthrizationStatus)status requestFailedToAuthorization:(NSError * _Nullable)error {
    NSLog(@"authorization failed: %@", error);
}
@end
