//
//  KRCamera.h
//
//  ilovekalvar@gmail.com
//
//  Created by Kuo-Ming Lin on 2012/08/01.
//  Copyright (c) 2012年 Kuo-Ming Lin. All rights reserved.
//


#import <UIKit/UIKit.h>

//相機運作模式
typedef enum _KRCameraModes {
    //相機模式
    KRCameraModesForCamera       = 0,
    //選取相簿模式
	KRCameraModesForSelectAlbum  = 1,
    //直接呈現全部的照片
    KRCameraModesForAllPhotos    = 2
} KRCameraModes;

@protocol KRCameraDelegate;

//截取影片示意圖用,需加入MediaPlayer.framework
//#import <MediaPlayer/MediaPlayer.h>

@interface KRCamera : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIViewController *parentTarget;
    id<KRCameraDelegate> __weak KRCameraDelegate;
    UIImagePickerController *imagePicker;
    //選擇使用"拍照"或"檔案選取"方式
    KRCameraModes sourceMode;
    //開啟或關閉影片(鏡頭)功能
    BOOL isOpenVideo;
    //是否儲存圖片或影片
    BOOL isAllowSave;
    //儲存的圖片
    //UIImage *savedImage;
    //儲存的影片位址
    //NSURL *videoUrl;
    //錄影品質
    UIImagePickerControllerQualityType videoQuality;
    //錄影最大秒數
    NSUInteger videoMaxSeconds;
    //是否允許編輯
    BOOL isAllowEditing;
    //取出幾秒的影片
    int videoMaxDuration;
    //是否只開啟錄影功能
    BOOL isOnlyVideo;
    //是否自動關閉
    BOOL autoClose;
    /*
     * 是否使用自訂義的 Toolbar 控制列 ?
     * 也就是原先官方的拍照按鈕會消失，而能改放自已客製化的按鈕上去，
     * 之後，使用自訂義的拍照按鈕時，就會直接進行拍照的 Delegate 和動作，
     * 而不會再進入「Preview」的確認畫面了。
     */
    BOOL showCameraControls;
    
}

@property (nonatomic, strong) UIViewController *parentTarget;
@property (nonatomic, weak) id<KRCameraDelegate> KRCameraDelegate;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, assign) KRCameraModes sourceMode;
@property (nonatomic, assign) BOOL isOpenVideo;
@property (nonatomic, assign) BOOL isAllowSave;
//@property (nonatomic, assign) UIImage *savedImage;
//@property (nonatomic, assign) NSURL *videoUrl;
@property (nonatomic, assign) UIImagePickerControllerQualityType videoQuality;
@property (nonatomic, assign) NSUInteger videoMaxSeconeds;
@property (nonatomic, assign) BOOL isAllowEditing;
@property (nonatomic, assign) int videoMaxDuration;
@property (nonatomic, assign) BOOL isOnlyVideo;
@property (nonatomic, assign) BOOL autoClose;
@property (nonatomic, assign) BOOL showCameraControls;

-(id)initWithDelete:(id<KRCameraDelegate>)_delegate pickerMode:(KRCameraModes)_pickerMode;
-(id)initWithDelegate:(id<KRCameraDelegate>)_delegate;
-(void)start;
-(void)remove;
-(void)cancel;
-(void)takePicture;

@end

@protocol KRCameraDelegate <NSObject>

@optional
//選取圖片、影片完成時 || 拍完照、錄完影後，要在這裡進行檔案的轉換、處理與儲存
-(void)krCameraDidFinishPickingMediaWithInfo:(NSDictionary *)_infos imagePickerController:(UIImagePickerController *)_imagePicker;
//對象是圖片
-(void)krCameraDidFinishPickingImage:(UIImage *)_image imagePath:(NSString *)_imagePath imagePickerController:(UIImagePickerController *)_imagePicker;
//對象是圖片並包含 EXIF / TIFF 等 MetaData 資訊
-(void)krCameraDidFinishPickingImage:(UIImage *)_image imagePath:(NSString *)_imagePath metadata:(NSDictionary *)_metadatas imagePickerController:(UIImagePickerController *)_imagePicker;
//對象是影片
-(void)krCameraDidFinishPickingVideoPath:(NSString *)_videoPath imagePickerController:(UIImagePickerController *)_imagePicker;
//按下取消時
-(void)krCameraDidCancel:(UIImagePickerController *)_imagePicker;


@end