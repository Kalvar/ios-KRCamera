//
//  KRCamera.m
//
//  ilovekalvar@gmail.com
//
//  Created by Kuo-Ming Lin on 2012/08/01.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "KRCamera.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "AssetsLibrary/AssetsLibrary.h"
#import "ImageIO/CGImageProperties.h"
#import <CoreLocation/CoreLocation.h>


@interface KRCamera (saveToAlbum)

-(void)saveImageAndAddMetadata:(UIImage *)image;
-(NSDictionary *)getGPSDictionaryForLocation;
-(void)_writeToAlbum:(NSDictionary *)info imagePicker:(UIImagePickerController *)picker;

@end

@implementation KRCamera (saveToAlbum)

//儲存帶有 EXIF, TIFF 等資訊的圖片至相簿
-(void)saveImageAndAddMetadata:(UIImage *)image
{
    // Format the current date and time
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    NSString *now = [formatter stringFromDate:[NSDate date]];
    
    // Exif metadata dictionary
    // Includes date and time as well as image dimensions
    NSMutableDictionary *exifDictionary = [NSMutableDictionary dictionary];
    [exifDictionary setValue:now forKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
    [exifDictionary setValue:now forKey:(NSString *)kCGImagePropertyExifDateTimeDigitized];
    [exifDictionary setValue:[NSNumber numberWithFloat:image.size.width] forKey:(NSString *)kCGImagePropertyExifPixelXDimension];
    [exifDictionary setValue:[NSNumber numberWithFloat:image.size.height] forKey:(NSString *)kCGImagePropertyExifPixelYDimension];
    
    // Tiff metadata dictionary
    // Includes information about the application used to create the image
    // "Make" is the name of the app, "Model" is the version of the app
    NSMutableDictionary *tiffDictionary = [NSMutableDictionary dictionary];
    [tiffDictionary setValue:now forKey:(NSString *)kCGImagePropertyTIFFDateTime];
    [tiffDictionary setValue:@"Interlacer" forKey:(NSString *)kCGImagePropertyTIFFMake];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [tiffDictionary setValue:[NSString stringWithFormat:@"%@ (%@)", version, build] forKey:(NSString *)kCGImagePropertyTIFFModel];
    
    // Image metadata dictionary
    // Includes image dimensions, as well as the EXIF and TIFF metadata
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSNumber numberWithFloat:image.size.width] forKey:(NSString *)kCGImagePropertyPixelWidth];
    [dict setValue:[NSNumber numberWithFloat:image.size.height] forKey:(NSString *)kCGImagePropertyPixelHeight];
    [dict setValue:exifDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    [dict setValue:tiffDictionary forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
    
    [al writeImageToSavedPhotosAlbum:[image CGImage]
                            metadata:dict
                     completionBlock:^(NSURL *assetURL, NSError *error) {
                         if (error == nil) {
                             if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidFinishPickingImage:imagePath:imagePickerController:)] ){
                                 [self.KRCameraDelegate krCameraDidFinishPickingImage:image
                                                                              imagePath:[NSString stringWithFormat:@"%@", assetURL]
                                                                  imagePickerController:self];
                             }
                         } else {
                             // handle error
                         }
                     }];
    
}

//取得 GPS 定位資訊
-(NSDictionary *)getGPSDictionaryForLocation{
    //Use LocationManager to Catch the GPS locations.
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
    CLLocation *location = locationManager.location;;
    [locationManager stopUpdatingLocation];
    NSMutableDictionary *gps = [NSMutableDictionary dictionary];
    
    // GPS tag version
    [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];
    
    // Time and date must be provided as strings, not as an NSDate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
    
    // Latitude
    CGFloat latitude = location.coordinate.latitude;
    if (latitude < 0) {
        latitude = -latitude;
        [gps setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } else {
        [gps setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    
    // Longitude
    CGFloat longitude = location.coordinate.longitude;
    if (longitude < 0) {
        longitude = -longitude;
        [gps setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } else {
        [gps setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    
    // Altitude
    CGFloat altitude = location.altitude;
    if (!isnan(altitude)){
        if (altitude < 0) {
            altitude = -altitude;
            [gps setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } else {
            [gps setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        }
        [gps setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }
    
    // Speed, must be converted from m/s to km/h
    if (location.speed >= 0){
        [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
        [gps setObject:[NSNumber numberWithFloat:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
    }
    
    // Heading
    if (location.course >= 0){
        [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
        [gps setObject:[NSNumber numberWithFloat:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
    }
    
    return gps;
}

//寫入相簿裡
-(void)_writeToAlbum:(NSDictionary *)info imagePicker:(UIImagePickerController *)picker{
    UIImage *savedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //儲存圖片(這樣存才能取得圖片 Path)
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    /*
    // Get the image metadata (EXIF & TIFF)
    NSMutableDictionary *_metadata = [[info objectForKey:UIImagePickerControllerMediaMetadata] mutableCopy];
    // add GPS data
    [_metadata setObject:[self getGPSDictionaryForLocation] forKey:(NSString*)kCGImagePropertyGPSDictionary];
    [library writeImageToSavedPhotosAlbum:[savedImage CGImage] metadata:_metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        if(error) {
            //NSLog(@"error");
        }else{
            if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidFinishPickingImage:imagePath:imagePickerController:)] ){
                [self.KRCameraDelegate krCameraDidFinishPickingImage:savedImage
                                                             imagePath:[NSString stringWithFormat:@"%@", assetURL]
                                                 imagePickerController:picker];
            }
            if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidFinishPickingImage:imagePath:metadata:imagePickerController:)] ){
                [self.KRCameraDelegate krCameraDidFinishPickingImage:savedImage
                                                             imagePath:[NSString stringWithFormat:@"%@", assetURL]
                 
                                                              metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                                                 imagePickerController:picker];
            }
        }
    }];
    */
    
    [library writeImageToSavedPhotosAlbum:[savedImage CGImage]
                              orientation:(ALAssetOrientation)[savedImage imageOrientation]
                          completionBlock:^(NSURL *assetURL, NSError *error){
                              if(error) {
                                  //NSLog(@"error");
                              }else{
                                  if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidFinishPickingImage:imagePath:imagePickerController:)] ){
                                      [self.KRCameraDelegate krCameraDidFinishPickingImage:savedImage
                                                                                   imagePath:[NSString stringWithFormat:@"%@", assetURL]
                                                                       imagePickerController:picker];
                                  }
                                  if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidFinishPickingImage:imagePath:metadata:imagePickerController:)] ){
                                      [self.KRCameraDelegate krCameraDidFinishPickingImage:savedImage
                                                                                   imagePath:[NSString stringWithFormat:@"%@", assetURL]
                                                                                    metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                                                                       imagePickerController:picker];
                                  }
                              }
                          }];
}

@end

@interface KRCamera (fixPrivate)

-(void)_initWithVars;
-(BOOL)_isIphone5;
-(void)_appearStatusBar:(BOOL)_isAppear;
-(NSString *)_resetVideoPath:(NSString *)_videoPath;
-(void)_setupConfigs;
//-(void)_resetTempMemories;

@end

@implementation KRCamera (fixPrivate)

-(void)_initWithVars
{
    self.parentTarget       = nil;
    self.sourceMode         = KRCameraModesForCamera;
    self.isOpenVideo        = YES;
    self.allowsSaveFile     = YES;
    self.isAllowEditing     = NO;
    self.videoQuality       = UIImagePickerControllerQualityTypeHigh;
    self.videoMaxSeconeds   = 15;
    self.videoMaxDuration   = -1;
    //savedImage            = [[UIImage alloc] init];
    //videoUrl              = [[NSURL alloc] init];
    self.isOnlyVideo        = NO;
    self.displaysCameraControls = YES;
    /*
     * @ 因為有自訂自已的 Setter
     */
    autoDismissPresent      = NO;
    autoRemoveFromSuperview = NO;
    
}

-(BOOL)_isIphone5
{
    CGRect _screenBounds = [[UIScreen mainScreen] bounds];
    if( _screenBounds.size.width > 480.0f && _screenBounds.size.width <= 568.0f ){
        return YES;
    }
    if( _screenBounds.size.height > 480.0f && _screenBounds.size.width <= 568.0f ){
        return YES;
    }
    return NO;
}

-(void)_appearStatusBar:(BOOL)_isAppear
{
    [[UIApplication sharedApplication] setStatusBarHidden:!_isAppear];
}

-(NSString *)_resetVideoPath:(NSString *)_videoPath
{
    //Temperatue Path of Recorded Video 
    ///private/var/mobile/Applications/F5D3F6CE-DD41-4FF1-94A4-9C0EBAC70AA3/tmp/capture-T0x232520.tmp.GL1Fg5/capturedvideo.MOV
    NSString *_rePath = @"";
    if( [_videoPath length] > 0 ){
        NSMutableArray *explodes = [NSMutableArray arrayWithArray:[_videoPath componentsSeparatedByString:@"/"]];
        [explodes removeObjectAtIndex:0];
        [explodes removeObjectAtIndex:[explodes count] - 2];
        for( NSString *_path in explodes ){
            _rePath = [_rePath stringByAppendingFormat:@"/%@", _path];
        }
    }
    return _rePath;
}

-(void)_setupConfigs
{
    //[self _resetTempMemories];
    //[self _appearStatusBar:NO];
    self.delegate      = self;
    self.allowsEditing = self.isAllowEditing;
    switch ( self.sourceMode ) {
        case KRCameraModesForCamera:
            //拍照或錄影
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                self.sourceType = UIImagePickerControllerSourceTypeCamera;
                //self.showsCameraControls = self.showCameraControls;
                //有錄影功能
                if ( self.isOpenVideo ) {
                    //只拍影片
                    if( self.isOnlyVideo ){
                        //限定相簿只能顯示影片檔
                        self.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
                    }else{
                        //NSArray *mediaTypes    = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
                        self.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
                    }
                    //設定影片品質
                    [self setVideoQuality:self.videoQuality];
                    //設定最大錄影時間(秒)
                    [self setVideoMaximumDuration:self.videoMaxSeconeds];
                }else{
                    self.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                }
            }
            self.allowsSaveFile = YES;
            break;
        case KRCameraModesForSelectAlbum:
            //從相簿選取
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                if ( self.isOpenVideo ) {
                    if( self.isOnlyVideo ){
                        //限定相簿只能顯示影片檔
                        self.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
                    }else{
                        //NSArray *mediaTypes    = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
                        self.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
                    }
                    //有指定取出的影片長度
                    if( self.videoMaxDuration > 0 ){
                        //一定要允許編輯
                        self.allowsEditing = YES;
                        self.videoMaximumDuration = self.videoMaxDuration;
                    }
                }else{
                    self.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                }
            }
            //從本機選取就不用再重複儲存檔案
            self.allowsSaveFile = NO;
            break;
        case KRCameraModesForAllPhotos:
            //直接呈現全部的照片
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                self.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                if ( self.isOpenVideo ) {
                    if( self.isOnlyVideo ){
                        //限定相簿只能顯示影片檔
                        self.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
                    }else{
                        //NSArray *mediaTypes    = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
                        self.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
                    }
                    if( self.videoMaxDuration > 0 ){
                        self.allowsEditing = YES;
                        self.videoMaximumDuration = self.videoMaxDuration;
                    }
                }else{
                    self.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                }
            }
            self.allowsSaveFile = NO;
            break;
    }
}

@end

@implementation KRCamera

@synthesize parentTarget;
@synthesize KRCameraDelegate;
@synthesize sourceMode;
@synthesize isOpenVideo;
@synthesize allowsSaveFile;
@synthesize videoQuality,
            videoMaxSeconeds,
            videoMaxDuration;
@synthesize isAllowEditing;
@synthesize isOnlyVideo;
@synthesize autoDismissPresent      = _autoDismissPresent;
@synthesize autoRemoveFromSuperview = _autoRemoveFromSuperview;
@synthesize displaysCameraControls;
//@synthesize savedImage;
//@synthesize videoUrl;

-(id)initWithDelete:(id<KRCameraDelegate>)_krCameraDelegate pickerMode:(KRCameraModes)_pickerMode
{
    self = [super init];
    if( self ){
        [self _initWithVars];
        self.KRCameraDelegate = _krCameraDelegate;
        self.sourceMode       = _pickerMode;
    }
    return self;
}

-(id)initWithDelegate:(id<KRCameraDelegate>)_krCameraDelegate
{
    self = [super init];
    if( self ){
        [self _initWithVars];
        self.KRCameraDelegate = _krCameraDelegate;
    }
    return self;
}

-(id)init
{
    self = [super init];
    if( self ){
        [self _initWithVars];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _initWithVars];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)didReceiveMemoryWarning
{
    //we're too important to get flushed out by our child imagepicker.
    [super didReceiveMemoryWarning];
    
}

#pragma MyMethods
/*
 * @ 執行相簿選擇
 */
-(void)startChoose
{
    [self _setupConfigs];
}

/*
 * @ 執行相機
 *   - 在拍照時就會 Received memory warning. 似乎是陳年的老 Bugs 真怪了 = =
 */
-(void)startCamera
{
    [self _setupConfigs];
    self.showsCameraControls = self.displaysCameraControls;
    CGRect _frame = self.view.frame;
    if( _frame.origin.y > 0.0f || _frame.origin.y < 0.0f )
    {
        _frame.origin.y = 0.0f;
    }
    [self.view setFrame:_frame];
}

-(void)wantToFullScreen
{
    [self hideStatusBar];
}

/*
 * @ 移除
 */
-(void)remove
{
    if( self.view.superview ){
        [self.view removeFromSuperview];
    }
    if( self.parentTarget ){
        self.parentTarget = nil;
    }
}

/*
 * @ 向下縮
 */
-(void)cancel
{
    //如使用睡眠後，才 dissmissView 的話，會產生 10004003 的 warning.
    //[NSThread sleepForTimeInterval:0.5];
    if( self.autoRemoveFromSuperview )
    {
        [self remove];
    }
    if( self.autoDismissPresent )
    {
        [self dismissViewControllerAnimated:YES completion:^{
            [self showStatusBar];
        }];
    }
}

/*
 * @ 拍照
 */
-(void)takeOnePicture
{
    [super takePicture];
    /*
    //@用這裡超單純的呼叫相機，拍照也還是會出現 Memory Warning XD
    //建立選取器
    imagePicker = [[UIImagePickerController alloc] init];
    //選取器的委派
    imagePicker.delegate = self;
    //選取器要進行動作的對象來源 : 手機相簿(PhotoLibrary) :: 共有 PhotoLibrary, Camera, SavedAlbum
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //選取器要進行動作的限定媒體檔類型
    //只能顯示圖片檔
    imagePicker.mediaTypes = [NSArray arrayWithObject:@"public.image"];
    //是否允許修改操作 ? NO : 點圖就完成選取 :: YES : 點圖還會進到修改畫面
    imagePicker.allowsEditing = NO;
    //顯示選取器
    [self presentModalViewController:imagePicker animated:YES];
    return;
    */
}

/*
 * @ 隱藏狀態列
 */
-(void)hideStatusBar
{
    [self _appearStatusBar:NO];
}

/*
 * @ 顯示狀態列
 */
-(void)showStatusBar
{
    [self _appearStatusBar:YES];
}

#pragma Setters
-(void)setAutoDismissPresent:(BOOL)_theAutoDismissPresent
{
    _autoDismissPresent = _theAutoDismissPresent;
    //_autoRemoveFromSuperview = !_autoDismissPresent;
}

-(void)setAutoRemoveFromSuperview:(BOOL)_theAutoRemoveFromSuperview
{
    _autoRemoveFromSuperview = _theAutoRemoveFromSuperview;
    //_autoDismissPresent = !_autoRemoveFromSuperview;
}

#pragma UIImagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidFinishPickingMediaWithInfo:imagePickerController:)] ){
        [self.KRCameraDelegate krCameraDidFinishPickingMediaWithInfo:info imagePickerController:picker];
    }
    //當開啟影片(鏡頭)功能時
    if ( self.isOpenVideo ) {
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.movie"]) {
            //來源為影片
            NSURL *videoUrl     = [info objectForKey:UIImagePickerControllerMediaURL];
            NSString *videoPath = videoUrl.path;
            ///*
            if (self.allowsSaveFile) {
                //直接存至相簿
                UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, nil, nil);
            }
            //即使是儲存影片後的暫存影片路徑，iPhone 都能夠找到並對應儲存前後的實體位置 (放心的使用這方式取得路徑，但需注意下次再進入 App 時，這暫存路徑會消失)。
            if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidFinishPickingVideoPath:imagePickerController:)] ){
                [self.KRCameraDelegate krCameraDidFinishPickingVideoPath:videoPath
                                                     imagePickerController:picker];
            }
             //*/
            /*
            if (self.allowsSaveFile) {
                //這樣才能取到正確儲存後的 Video Path ( 但取到的 Path 必須用 Asset 解析 ...  )
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeVideoAtPathToSavedPhotosAlbum:videoUrl
                                            completionBlock:^(NSURL *assetURL, NSError *error) {
                                                if(error) {
                                                    //NSLog(@"error");
                                                }else{
                                                    if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidFinishPickingVideoPath:imagePickerController:)] ){
                                                        [self.KRCameraDelegate krCameraDidFinishPickingVideoPath:[NSString stringWithFormat:@"%@", assetURL]
                                                                                             imagePickerController:picker];
                                                    }
                                                }
                                            }];
                [library release];
                //儲存影片檔
                //UISaveVideoAtPathToSavedPhotosAlbum(videoUrl.path, self, nil, nil);
            }else{
                if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidFinishPickingVideoPath:imagePickerController:)] ){
                    [self.KRCameraDelegate krCameraDidFinishPickingVideoPath:videoUrl.path
                                                         imagePickerController:picker];
                }
            }
             */
        }else if ([mediaType isEqualToString:@"public.image"]) {
            //來源為圖片
            if (self.allowsSaveFile) {
                [self _writeToAlbum:info imagePicker:picker];
                //UIImageWriteToSavedPhotosAlbum(savedImage, self, nil, nil);
            }else{
                if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidFinishPickingImage:imagePath:imagePickerController:)] ){
                    [self.KRCameraDelegate krCameraDidFinishPickingImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"]
                                                                 imagePath:[NSString stringWithFormat:@"%@", [info objectForKey:UIImagePickerControllerReferenceURL]]
                                                     imagePickerController:picker];
                }
            }
        }
    }else {
        //當關閉影片功能時
        if (self.allowsSaveFile) {
            [self _writeToAlbum:info imagePicker:picker];
            //UIImageWriteToSavedPhotosAlbum(savedImage, self, nil, nil);
        }else{
            if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidFinishPickingImage:imagePath:imagePickerController:)] ){
                [self.KRCameraDelegate krCameraDidFinishPickingImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"]
                                                             imagePath:[NSString stringWithFormat:@"%@", [info objectForKey:UIImagePickerControllerReferenceURL]]
                                                 imagePickerController:picker];
            }
        }

    }
    //[self remove];
    [self cancel];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self cancel];
    if( [self.KRCameraDelegate respondsToSelector:@selector(krCameraDidCancel:)] ){
        [self.KRCameraDelegate krCameraDidCancel:picker];
    }
}

#pragma NavigationDelegate
-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated{
    
    //NSLog(@"here 1");

}

-(void)navigationController:(UINavigationController *)navigationController
      didShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated{
    
    //NSLog(@"here 2");
    
}

@end
