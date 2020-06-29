//
//  TTTVideoChatViewController.m
//  TTTCosmosBeauty
//

#import "TTTVideoChatViewController.h"
#import "TTTAVRegion.h"
#import <MMBeautyKit/MMRenderModuleManager.h>
#import <MMBeautyKit/MMRenderFilterBeautyModule.h>

@interface TTTVideoChatViewController () <TTTRtcEngineDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *meImgView;
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UISlider *sliderBeautyRubby;
@property (weak, nonatomic) IBOutlet UISlider *sliderBeautyBigEye;
@property (weak, nonatomic) IBOutlet UISlider *sliderBeautyThinFace;
@property (weak, nonatomic) IBOutlet UISlider *sliderBeautyWhitening;
@property (weak, nonatomic) IBOutlet UISlider *sliderBeautySmooth;
@property (weak, nonatomic) IBOutlet UISwitch *switchBeautyRubby;
@property (weak, nonatomic) IBOutlet UISwitch *switchBeautyBigEye;
@property (weak, nonatomic) IBOutlet UISwitch *switchBeautyThinFace;
@property (weak, nonatomic) IBOutlet UISwitch *switchBeautyWhitening;
@property (weak, nonatomic) IBOutlet UISwitch *switchBeautySmooth;

@property (nonatomic, strong) NSMutableArray<TTTAVRegion *> *avRegions;
@property (nonatomic, strong) NSMutableArray<TTTUser *> *users;

@property (nonatomic, strong) MMRenderModuleManager *renderModule;
@property (nonatomic, strong) MMRenderFilterBeautyModule *beautyModule;

@property (nonatomic, assign) float beautyRubby;
@property (nonatomic, assign) float beautyBigEye;
@property (nonatomic, assign) float beautyThinFace;
@property (nonatomic, assign) float beautyWhitening;
@property (nonatomic, assign) float beautySmooth;

@end

@implementation TTTVideoChatViewController
{
    BOOL _isBeautyEnabled;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.renderModule = [[MMRenderModuleManager alloc] init];
    self.renderModule.devicePosition = AVCaptureDevicePositionFront;
    self.renderModule.inputType = MMRenderInputTypeStream;
    self.beautyModule = [[MMRenderFilterBeautyModule alloc] init];
    [self.renderModule registerFilterModule:self.beautyModule];
    
    _isBeautyEnabled = YES;
    self.beautyRubby = self.sliderBeautyRubby.value;
    self.beautyBigEye = self.sliderBeautyBigEye.value;
    self.beautyThinFace = self.sliderBeautyThinFace.value;
    self.beautyWhitening = self.sliderBeautyWhitening.value;
    self.beautySmooth = self.sliderBeautySmooth.value;
    
    _avRegions = [NSMutableArray array];
    _users = [NSMutableArray array];
    _roomIDLabel.text = [NSString stringWithFormat:@"房号: %lld", TTTManager.roomID];
    _idLabel.text = [NSString stringWithFormat:@"ID: %lld", TTTManager.me.uid];
    TTTManager.rtcEngine.delegate = self;
    TTTRtcVideoCanvas *videoCanvas = [[TTTRtcVideoCanvas alloc] init];
    videoCanvas.uid = TTTManager.me.uid;
    videoCanvas.renderMode = TTTRtc_Render_Adaptive;
    videoCanvas.view = _meImgView;
    [TTTManager.rtcEngine setupLocalVideo:videoCanvas];
}

- (void)setBeautyRubby:(float)beautyRubby {
    _beautyRubby = beautyRubby;
    [self.beautyModule setBeautyFactor:_beautyRubby forKey:kBeautyFilterKeyRubby];
}

- (void)setBeautyBigEye:(float)beautyBigEye {
    _beautyBigEye = beautyBigEye;
    [self.beautyModule setBeautyFactor:_beautyBigEye forKey:kBeautyFilterKeyBigEye];
}

- (void)setBeautyThinFace:(float)beautyThinFace {
    _beautyThinFace = beautyThinFace;
    [self.beautyModule setBeautyFactor: _beautyThinFace forKey:kBeautyFilterKeyThinFace];
}

- (void)setBeautyWhitening:(float)beautyWhitening {
    _beautyWhitening = beautyWhitening;
    [self.beautyModule setBeautyFactor:_beautyWhitening forKey:kBeautyFilterKeyWhitening];
}

- (void)setBeautySmooth:(float)beautySmooth {
    _beautySmooth = beautySmooth;
    [self.beautyModule setBeautyFactor:_beautySmooth forKey:kBeautyFilterKeySmooth];
}

- (IBAction)sliderBeautyRubbyValueChanged:(id)sender {
    self.beautyRubby = self.sliderBeautyRubby.value;
}

- (IBAction)sliderBeautyBigEyeValueChanged:(id)sender {
    self.beautyBigEye = self.sliderBeautyBigEye.value;
}

- (IBAction)sliderBeautyThinFaceValueChanged:(id)sender {
    self.beautyThinFace = self.sliderBeautyThinFace.value;
}

- (IBAction)sliderBeautyWhiteningValueChanged:(id)sender {
    self.beautyWhitening = self.sliderBeautyWhitening.value;
}

- (IBAction)sliderBeautySmoothValueChanged:(id)sender {
    self.beautySmooth = self.sliderBeautySmooth.value;
}

- (BOOL)isBeautyEnabled {
    return self.switchBeautyRubby.on || self.switchBeautyBigEye.on || self.switchBeautyThinFace.on
        || self.switchBeautyWhitening.on || self.switchBeautySmooth.on;
}

- (IBAction)switchBeautyRubbyValueChanged:(id)sender {
    self.sliderBeautyRubby.enabled = self.switchBeautyRubby.on;
    self.beautyRubby = self.switchBeautyRubby.on ? self.sliderBeautyRubby.value : 0;
    _isBeautyEnabled = [self isBeautyEnabled];
}

- (IBAction)switchBeautyBigEyeValueChanged:(id)sender {
    self.sliderBeautyBigEye.enabled = self.switchBeautyBigEye.on;
    self.beautyBigEye = self.switchBeautyBigEye.on ? self.sliderBeautyBigEye.value : 0;
    _isBeautyEnabled = [self isBeautyEnabled];
}

- (IBAction)switchBeautyThinFaceValueChanged:(id)sender {
    self.sliderBeautyThinFace.enabled = self.switchBeautyThinFace.on;
    self.beautyThinFace = self.switchBeautyThinFace.on ? self.sliderBeautyThinFace.value : 0;
    _isBeautyEnabled = [self isBeautyEnabled];
}

- (IBAction)switchBeautyWhiteningValueChanged:(id)sender {
    self.sliderBeautyWhitening.enabled = self.switchBeautyWhitening.on;
    self.beautyWhitening = self.switchBeautyWhitening.on ? self.sliderBeautyWhitening.value : 0;
    _isBeautyEnabled = [self isBeautyEnabled];
}

- (IBAction)switchBeautySmoothValueChanged:(id)sender {
    self.sliderBeautySmooth.enabled = self.switchBeautySmooth.on;
    self.beautySmooth = self.switchBeautySmooth.on ? self.sliderBeautySmooth.value : 0;
    _isBeautyEnabled = [self isBeautyEnabled];
}

- (IBAction)leftBtnsAction:(UIButton *)sender {
    if (sender.tag == 1001) {
        [TTTManager.rtcEngine switchCamera];
    } else if (sender.tag == 1002) {
        sender.selected = !sender.isSelected;
        TTTManager.me.mutedSelf = sender.isSelected;
        [TTTManager.rtcEngine muteLocalAudioStream:sender.isSelected];
    }
}

- (IBAction)exitChannel:(id)sender {
    __weak TTTVideoChatViewController *weakSelf = self;
    UIAlertController *alert  = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要退出房间吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [TTTManager.rtcEngine leaveChannel:nil];
        [TTTManager.rtcEngine stopPreview];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)copyPixelBuffer:(CVPixelBufferRef)srcPixelBuffer toPixelBuffer:(CVPixelBufferRef)dstPixelBuffer {
    CVPixelBufferLockBaseAddress(srcPixelBuffer, 0);
    int bufferHeight = (int)CVPixelBufferGetHeight(srcPixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(srcPixelBuffer);
    uint8_t *srcBaseAddress = CVPixelBufferGetBaseAddress(srcPixelBuffer);
    
    CVPixelBufferLockBaseAddress(dstPixelBuffer, 0);
    uint8_t *dstBaseAddress = CVPixelBufferGetBaseAddress(dstPixelBuffer);
    memcpy(dstBaseAddress, srcBaseAddress, bufferHeight * bytesPerRow);
    
    CVPixelBufferUnlockBaseAddress(dstPixelBuffer, 0);
    CVPixelBufferUnlockBaseAddress(srcPixelBuffer, 0);
}

#pragma mark - TTTRtcEngineDelegate
- (void)rtcEngine:(TTTRtcEngineKit *)engine localVideoFrameCaptured:(TTTRtcVideoFrame *)videoFrame {
    if (_isBeautyEnabled) {
        NSError *error = nil;
        CVPixelBufferRef renderedPixelBuffer = [self.renderModule renderPixelBuffer:videoFrame.textureBuffer error:&error];
        if (error == nil) {
            [self copyPixelBuffer:renderedPixelBuffer toPixelBuffer:videoFrame.textureBuffer];
        } else {
            NSLog(@"renderPixelBuffer error: %@", error.localizedDescription);
        }
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine reportAudioLevel:(int64_t)userID audioLevel:(NSUInteger)audioLevel audioLevelFullRange:(NSUInteger)audioLevelFullRange {
    if (userID == TTTManager.me.uid) {
        [_voiceBtn setImage:[self getVoiceImage:audioLevel] forState:UIControlStateNormal];
    } else {
        [[self getAVRegion:userID] reportAudioLevel:audioLevel];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didAudioMuted:(BOOL)muted byUid:(int64_t)uid {
    TTTUser *user = [self getUser:uid];
    if (!user) { return; }
    user.mutedSelf = muted;
    [[self getAVRegion:uid] mutedSelf:muted];
}

- (void)rtcEngineConnectionDidLost:(TTTRtcEngineKit *)engine {
    [TTProgressHud showHud:self.view message:@"网络链接丢失，正在重连..."];
}

- (void)rtcEngineReconnectServerTimeout:(TTTRtcEngineKit *)engine {
    [TTProgressHud hideHud:self.view];
    [self.view.window showToast:@"网络丢失，请检查网络"];
    [engine leaveChannel:nil];
    [engine stopPreview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rtcEngineReconnectServerSucceed:(TTTRtcEngineKit *)engine {
    [TTProgressHud hideHud:self.view];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didKickedOutOfUid:(int64_t)uid reason:(TTTRtcKickedOutReason)reason {
    NSString *errorInfo = @"";
    switch (reason) {
        case TTTRtc_KickedOut_ReLogin:
            errorInfo = @"重复登录";
            break;
        case TTTRtc_KickedOut_NoAudioData:
            errorInfo = @"长时间没有上行音频数据";
            break;
        case TTTRtc_KickedOut_NoVideoData:
            errorInfo = @"长时间没有上行视频数据";
            break;
        case TTTRtc_KickedOut_ChannelKeyExpired:
            errorInfo = @"Channel Key失效";
            break;
        default:
            errorInfo = @"未知错误";
            break;
    }
    [self.view.window showToast:errorInfo];
    [engine leaveChannel:nil];
    [engine stopPreview];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - helper mehtod
- (TTTAVRegion *)getAvaiableAVRegion {
    __block TTTAVRegion *region = nil;
    [_avRegions enumerateObjectsUsingBlock:^(TTTAVRegion * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.user) {
            region = obj;
            *stop = YES;
        }
    }];
    return region;
}

- (TTTAVRegion *)getAVRegion:(int64_t)uid {
    __block TTTAVRegion *region = nil;
    [_avRegions enumerateObjectsUsingBlock:^(TTTAVRegion * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.user.uid == uid) {
            region = obj;
            *stop = YES;
        }
    }];
    return region;
}

- (TTTUser *)getUser:(int64_t)uid {
    __block TTTUser *user = nil;
    [_users enumerateObjectsUsingBlock:^(TTTUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.uid == uid) {
            user = obj;
            *stop = YES;
        }
    }];
    return user;
}

- (UIImage *)getVoiceImage:(NSUInteger)level {
//    BOOL speakerphone = _routing != TTTRtc_AudioOutput_Headset;
    BOOL speakerphone = YES;
    if (TTTManager.me.mutedSelf) {
        return [UIImage imageNamed:speakerphone ? @"voice_close" : @"tingtong_close"];
    }
    UIImage *image = nil;
    if (level < 4) {
        image = [UIImage imageNamed:speakerphone ? @"voice_small" : @"tingtong_small"];
    } else if (level < 7) {
        image = [UIImage imageNamed:speakerphone ? @"voice_middle" : @"tingtong_middle"];
    } else {
        image = [UIImage imageNamed:speakerphone ? @"voice_big" : @"tingtong_big"];
    }
    return image;
}

@end
