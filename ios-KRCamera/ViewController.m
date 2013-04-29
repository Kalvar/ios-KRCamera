//
//  ViewController.m
//  ios-KRCamera
//
//  Created by Kalvar on 13/3/17.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "ViewController.h"
#import "KRCamera.h"

@interface ViewController ()<KRCameraDelegate>

@property (nonatomic, strong) KRCamera *_krCamera;

@end

@implementation ViewController

@synthesize _krCamera;

- (void)viewDidLoad
{
    [super viewDidLoad];
	_krCamera = [[KRCamera alloc] initWithDelegate:self];
    /*
     * @ 如果是要使用 addSubview 作全螢幕的呈現 ( Full Screen )
     *   - 就要在 viewDidLoad 這裡先執行 wantToFullScreen 函式將狀態列隱藏 ( Hide the Status Bar )。
     */
    [self._krCamera wantToFullScreen];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma KRCameraDelegate
-(IBAction)takePicture:(id)sender
{
    /*
     * @ 如果 Device 支援相機
     */
    if( self._krCamera.isSupportCamera )
    {
        self._krCamera.isOpenVideo             = NO;
        self._krCamera.sourceMode              = KRCameraModesForCamera;
        self._krCamera.displaysCameraControls  = NO;
        [self._krCamera startCamera];
        /*
         * @ 如果要用 presentViewController 的模式啟動相機，就不需要在 viewDidLoad 裡執行 wantToFullScreen 方法。
         */
        //[self presentViewController:self._krCamera animated:YES completion:nil];
        if( [self._krCamera isIpadDevice] )
        {
            /*
             * @ 如果是 iPad
             */
            self._krCamera.autoDismissPresent      = YES;
            self._krCamera.autoRemoveFromSuperview = NO;
            [self._krCamera displayPopoverFromView:self.view inView:self.view];
        }
        else
        {
            /*
             * @ 如果要用 addSubview 的模式啟動相機，就要先在 viewDidLoad 裡執行 wantToFullScreen 方法先隱藏狀態列。
             */
            self._krCamera.autoDismissPresent      = NO;
            self._krCamera.autoRemoveFromSuperview = YES;
            [self.view addSubview:self._krCamera.view];
        }
    }
}

-(IBAction)choosePicture:(id)sender
{
    self._krCamera.isOpenVideo             = NO;
    self._krCamera.sourceMode              = KRCameraModesForSelectAlbum;
    [self._krCamera startChoose];
    if( [self._krCamera isIpadDevice] )
    {
        /*
         * @ 如果是 iPad
         */
        self._krCamera.autoDismissPresent      = NO;
        self._krCamera.autoRemoveFromSuperview = YES;
        [self._krCamera displayPopoverFromView:self.view inView:self.view];
    }
    else
    {
        /*
         * @ 如果要用 addSubview 的模式啟動相機，就要先在 viewDidLoad 裡執行 wantToFullScreen 方法先隱藏狀態列。
         */
        self._krCamera.autoDismissPresent      = YES;
        self._krCamera.autoRemoveFromSuperview = NO;
        [self presentViewController:self._krCamera animated:YES completion:nil];
    }
}

#pragma KRCameraDelegate
/*
 * @ 按下取消時
 */
-(void)krCameraDidCancel:(UIImagePickerController *)_imagePicker
{
    //[_imagePicker dismissViewControllerAnimated:YES completion:nil];
    //[_imagePicker.view removeFromSuperview];
    if( [self._krCamera isIpadDevice] )
    {
        [self._krCamera dismissPopover];
    }
    NSLog(@"cancel");
}

/*
 * @ 原始選取圖片、影片完成時，或拍完照、錄完影後
 *   - 要在這裡進行檔案的轉換、處理與儲存
 */
-(void)krCameraDidFinishPickingMediaWithInfo:(NSDictionary *)_infos imagePickerController:(UIImagePickerController *)_imagePicker
{
    
}

/*
 * @ 對象是圖片並包含 EXIF / TIFF 等 MetaData 資訊
 */
-(void)krCameraDidFinishPickingImage:(UIImage *)_image imagePath:(NSString *)_imagePath metadata:(NSDictionary *)_metadatas imagePickerController:(UIImagePickerController *)_imagePicker
{
    
    //NSLog(@"meta : %@", _metadatas);
    
}

/*
 * @ 對象是圖片
 */
-(void)krCameraDidFinishPickingImage:(UIImage *)_image imagePath:(NSString *)_imagePath imagePickerController:(UIImagePickerController *)_imagePicker
{
    /*
     * @ 在這裡上傳與剪裁選擇好的圖片
     */
    //[_imagePicker dismissViewControllerAnimated:YES completion:nil];
    //[_imagePicker.view removeFromSuperview];
    NSLog(@"Done Picking");
    //[self._krCamera showStatusBar];
}

/*
 * @ 對象是影片
 */
-(void)krCameraDidFinishPickingVideoPath:(NSString *)_videoPath imagePickerController:(UIImagePickerController *)_imagePicker
{
    
}

@end
