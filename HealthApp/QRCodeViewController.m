//
//  QRCodeViewController.m
//  Neediator
//
//  Created by adverto on 21/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "QRCodeViewController.h"



@interface QRCodeViewController ()


@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonnull, strong) NeediatorHUD *neediatorHUD;
@property (nonatomic) BOOL isReading;


-(BOOL)startReading;
-(void)stopReading;
-(void)loadBeepSound;

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self startStopReading];
    
//    self.overlayImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.view.frame.size.width <= 768) {
            self.overlayImageView.image = [UIImage imageNamed:@"iPad-768x1024"];
        }
        else if (self.view.frame.size.width >= 1536) {
            self.overlayImageView.image = [UIImage imageNamed:@"iPad-1536x2048"];
        }
    }
    else {
        if (self.view.frame.size.width <= 750) {
            self.overlayImageView.image = [UIImage imageNamed:@"iPhone6_(750 x 1334)"];
        }
        else if (self.view.frame.size.width >= 1242) {
            self.overlayImageView.image = [UIImage imageNamed:@"iPhone6_plus(1242 x 2208)"];
        }
    }
    
    [self.view bringSubviewToFront:self.overlayImageView];
    [self showHUD];
    
    
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avCaptureInputPortFormatDescriptionDidChangeNotification:) name:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)showHUD {
    
    self.neediatorHUD = [[NeediatorHUD alloc] initWithFrame:self.view.frame];
    self.neediatorHUD.overlayColor = [UIColor clearColor];
    self.neediatorHUD.shadowColor = [UIColor clearColor];
    self.neediatorHUD.imageSize = CGSizeMake(60.f, 60.f);
    [self.neediatorHUD fadeInAnimated:YES];
    self.neediatorHUD.hudCenter = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) / 2 + (CGRectGetWidth(self.view.bounds)/5));
    [self.navigationController.view insertSubview:self.neediatorHUD belowSubview:self.navigationController.navigationBar];
    
    
}

-(void)hideHUD {
    [self.neediatorHUD fadeOutAnimated:YES];
    [self.neediatorHUD removeFromSuperview];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"QRCode Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self hideHUD];
}

//-(void)avCaptureInputPortFormatDescriptionDidChangeNotification:(NSNotification *)notification {
//    
//    CGFloat width = CGRectGetWidth(self.view.frame);
//    CGFloat height = CGRectGetHeight(self.view.frame);
//    _captureMetadataOutput.rectOfInterest = CGRectMake(width/4, height/7, 400, 400);
//}

-(void)startStopReading {
    
    
    if (!_isReading) {
        // This is the case where the app should read a QR code when the start button is tapped.
        if ([self startReading]) {
            // If the startReading methods returns YES and the capture session is successfully
            // running, then change the start button title and the status message.
            
            [self.descriptionLabel setText:@"Scanning for QR Code..."];
        }
    }
    else{
        // In this case the app is currently reading a QR code and it should stop doing so.
        [self stopReading];
        // The bar button item's title should change again.
    }
    
    // Set to the flag the exact opposite value of the one that currently has.
    _isReading = !_isReading;
    
}


#pragma mark - Private method implementation

- (BOOL)startReading {
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    
    _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    _captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:_captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [_captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.view.layer.bounds];
    
    
    
//    CGFloat width = CGRectGetWidth(self.view.frame);
//    CGFloat height = CGRectGetHeight(self.view.frame);
    
    
//    CGRect visibleMetaDataOutputRect = [_videoPreviewLayer metadataOutputRectOfInterestForRect:CGRectMake(width/4, height/7, 400, 400)];
//    
//    
//    [_captureMetadataOutput setRectOfInterest:visibleMetaDataOutputRect];
//    
//    NSLog(@"%@", NSStringFromCGRect(CGRectMake(width/4, height/7, 400, 400)));
    
    
    [self.view.layer addSublayer:_videoPreviewLayer];
    
    
    // Start video capture.
    [_captureSession startRunning];
    
    return YES;
}


-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
}


-(void)loadBeepSound{
    // Get the path to the beep.mp3 file and convert it to a NSURL object.
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    
    NSError *error;
    
    // Initialize the audio player object using the NSURL object previously set.
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        // If the audio player cannot be initialized then log a message.
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        // If the audio player was successfully initialized then load it in memory.
        [_audioPlayer prepareToPlay];
    }
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        
        
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // If the found metadata is equal to the QR code metadata then update the status label's text,
            // stop reading and change the bar button item's title and the flag's value.
            // Everything is done on the main thread.
            [self.descriptionLabel performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
//            [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            
            _isReading = NO;
            
            // If the audio player is not nil, then play the sound effect.
            if (_audioPlayer) {
                [_audioPlayer play];
            }
        }
    }
    
    
}




@end
