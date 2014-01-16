//
//  SOSCameraViewController.m
//  Barcodes
//
//  Created by Sam Symons on 1/14/2014.
//  Copyright (c) 2014 Sam Symons. All rights reserved.
//

#import "SOSCameraViewController.h"
#import "SOSBrowserViewController.h"
#import "SOSBarcodeInformation.h"
#import "SOSBarcodeInformationRequest.h"

#import "TSMessage.h"

@interface SOSCameraViewController ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;

@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) CALayer *barcodeIndicatorLayer;

@property (nonatomic, strong) UIButton *torchToggleButton;

- (AVCaptureDevice *)backCamera;
- (void)presentBrowserViewControllerWithInformation:(SOSBarcodeInformation *)information;

- (void)startCapturingMetadata;
- (void)stopCapturingMetadata;

- (void)toggleTorch;

@end

@implementation SOSCameraViewController

- (instancetype)init
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
        self.view.backgroundColor = [UIColor blackColor];
    }
    
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShouldBeginCapturingMetadataNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TSMessage setDefaultViewController:self];
    
    // Set up the capture session:
    
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureDevice = [self backCamera];

    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // Add the device input:
    
    NSError *deviceInputError;
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:&deviceInputError];
    
    if ([[self captureSession] canAddInput:self.captureDeviceInput])
    {
        [[self captureSession] addInput:self.captureDeviceInput];
    }
    
    // Add the metadata output:
    
    [self startCapturingMetadata];
    
    // Add the preview layer and start capturing:
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.frame = self.view.frame;
    
    [[[self view] layer] addSublayer:self.previewLayer];
    
    [[self captureSession] startRunning];
    
    // Set up torch button, with layout constraints:
    
    if ([[self captureDevice] hasTorch])
    {
        [[self view] addSubview:self.torchToggleButton];
        [[self torchToggleButton] addTarget:self action:@selector(toggleTorch) forControlEvents:UIControlEventTouchUpInside];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCapturingMetadata) name:kShouldBeginCapturingMetadataNotification object:nil];
        
        NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:self.torchToggleButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:0.0f constant:10.0f];
        
        NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:self.torchToggleButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:0.0f constant:10.0f];
        
        [[self view] addConstraint:verticalConstraint];
        [[self view] addConstraint:horizontalConstraint];
    }
}

- (AVCaptureMetadataOutput *)metadataOutput
{
    if (!_metadataOutput)
    {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    
    return _metadataOutput;
}

- (CALayer *)barcodeIndicatorLayer
{
    if (!_barcodeIndicatorLayer)
    {
        _barcodeIndicatorLayer = [CALayer layer];
        _barcodeIndicatorLayer.opacity = 0.75;
        _barcodeIndicatorLayer.backgroundColor = [[UIColor redColor] CGColor];
        
        [[self previewLayer] addSublayer:_barcodeIndicatorLayer];
    }
    
    return _barcodeIndicatorLayer;
}

- (UIButton *)torchToggleButton
{
    if (!_torchToggleButton)
    {
        _torchToggleButton = [[UIButton alloc] init];
        _torchToggleButton.alpha = 1.0;
        _torchToggleButton.tintColor = [UIColor whiteColor];
        _torchToggleButton.translatesAutoresizingMaskIntoConstraints = NO;
        _torchToggleButton.accessibilityLabel = NSLocalizedString(@"Activate Flash", @"Activate Flash");
        
        UIImage *torchImage = [UIImage imageNamed:@"Torch"];
        torchImage = [torchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [_torchToggleButton setImage:torchImage forState:UIControlStateNormal];
    }
    
    return _torchToggleButton;
}

#pragma mark - Private

- (AVCaptureDevice *)backCamera
{
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device hasMediaType:AVMediaTypeVideo] && [device position] == AVCaptureDevicePositionBack)
        {
            return device;
        }
    }
    
    return nil;
}

- (void)presentBrowserViewControllerWithInformation:(SOSBarcodeInformation *)information
{   
    SOSBrowserViewController *browserViewController = [[SOSBrowserViewController alloc] initWithSearch:[information itemInformation]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:browserViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)startCapturingMetadata
{
    if ([[self captureSession] canAddOutput:self.metadataOutput])
    {
        [[self captureSession] addOutput:self.metadataOutput];
    }
    
    self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code];
}

- (void)stopCapturingMetadata
{
    [[self captureSession] removeOutput:self.metadataOutput];
}

- (void)toggleTorch
{
    BOOL torchCurrentlyOff = [[self captureDevice] torchMode] == AVCaptureTorchModeOff;
    AVCaptureTorchMode torchMode = torchCurrentlyOff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    
    NSError *configurationLock = nil;
    
    if ([[self captureDevice] lockForConfiguration:&configurationLock])
    {
        [[self captureDevice] setTorchMode:torchMode];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self stopCapturingMetadata];
    
    AVMetadataMachineReadableCodeObject *barcode = [metadataObjects firstObject];
    
    [TSMessage showNotificationWithTitle:@"Barcode detected" subtitle:@"Searching for information..." type:TSMessageNotificationTypeSuccess];
    
    [SOSBarcodeInformationRequest informationForUPC:barcode.stringValue completion:^(SOSBarcodeInformation *barcodeInformation, NSError *error) {
        [TSMessage dismissActiveNotification];
        
        if (!error)
        {
            [self presentBrowserViewControllerWithInformation:barcodeInformation];
        }
        else
        {
            [TSMessage showNotificationWithTitle:@"Invalid barcode" subtitle:nil type:TSMessageNotificationTypeError];
            [self startCapturingMetadata];
        }
    }];
}

@end
