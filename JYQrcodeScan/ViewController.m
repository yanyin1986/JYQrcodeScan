//
//  ViewController.m
//  JYQrcodeScan
//
//  Created by Leon.yan on 27/07/2016.
//  Copyright © 2016 Jilu+Leon. All rights reserved.
//

@import AVFoundation;

#import "ViewController.h"

// views
#import "JQScanView.h"

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, weak  ) IBOutlet UIView *previewView;
@property (nonatomic, weak  ) IBOutlet JQScanView *scanView;

@property (nonatomic, strong) NSDate *checkStartTime;
@property (nonatomic, strong) NSString *qrcode;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) dispatch_queue_t scanQueue;

@end

@implementation ViewController

- (void)wcheckAVCaptureDeviceAuthorizationForMediaType:(NSString *)type
                                           resultBlock:(void (^)(BOOL granted))result
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:type];
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:type
                                 completionHandler:result];
    } else {
        result(status == AVAuthorizationStatusAuthorized);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _scanQueue = dispatch_queue_create("wowtech.qrscan.queue", NULL);
    
    __weak __typeof(self) weakSelf = self;
    void(^block)(BOOL) = ^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf startScan];
            });
        }
    };
    [self wcheckAVCaptureDeviceAuthorizationForMediaType:AVMediaTypeVideo resultBlock:block];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_scanView stopAnimation];
    [_captureSession stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)startScan
{
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (!input) {
        NSLog(@"%@", error);
        return NO;
    }
    
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession addInput:input];
        
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        [_captureSession addOutput:output];
        
        // 设置一个扫描区域
        // 一般，iphone的摄像头的图像都是4:3的，所以这边设置一个中间的区域
        // 根据需求，把框定在中间的240x240的框内
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat offsetX = (screenSize.width - 240) / 2.0;
        CGFloat offsetY = (screenSize.height - 240) / 2.0;
        
        [output setRectOfInterest:CGRectMake(offsetY / screenSize.height,
                                             offsetX / screenSize.width,
                                             240.0 / screenSize.height,
                                             240.0 / screenSize.width)];
        // 设置一个扫描的代理和队列
        [output setMetadataObjectsDelegate:self queue:_scanQueue];
        // 设置扫描内容的类型
        [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_previewLayer setFrame:_previewView.bounds];
        [_previewView.layer addSublayer:_previewLayer];
    }
    
    [_captureSession startRunning];
    [_scanView startAnimation];
    
    return YES;
}

#pragma mark -  AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *obj = [metadataObjects firstObject];
        
        if ([obj.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            _qrcode = obj.stringValue;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_captureSession stopRunning];
                [_scanView stopAnimation];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:_qrcode delegate:self cancelButtonTitle:@"confirm" otherButtonTitles:nil];
                [alertView show];
            });
            
        }
    }
}

#pragma mark -  UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_captureSession startRunning];
    [_scanView startAnimation];
}

@end


