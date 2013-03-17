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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma KRCameraDelegate
/*
 * @ 上傳圖片
 */
-(IBAction)takePicture:(id)sender
{
    self._krCamera.isOpenVideo = NO;
    self._krCamera.sourceMode  = KRCameraModesForCamera;
    [self._krCamera start];
    [self presentViewController:self._krCamera animated:YES completion:nil];
}

-(IBAction)choosePicture:(id)sender
{
    self._krCamera.isOpenVideo = NO;
    self._krCamera.sourceMode  = KRCameraModesForSelectAlbum;
    [self._krCamera start];
    [self presentViewController:self._krCamera animated:YES completion:nil];
}

#pragma KRCameraDelegate
-(void)krCameraDidCancel:(UIImagePickerController *)_imagePicker{
    
}

-(void)krCameraDidFinishPickingMediaWithInfo:(NSDictionary *)_infos imagePickerController:(UIImagePickerController *)_imagePicker{
    
}

-(void)krCameraDidFinishPickingImage:(UIImage *)_image imagePath:(NSString *)_imagePath metadata:(NSDictionary *)_metadatas imagePickerController:(UIImagePickerController *)_imagePicker{
    
    //NSLog(@"meta : %@", _metadatas);
    
}

-(void)krCameraDidFinishPickingImage:(UIImage *)_image imagePath:(NSString *)_imagePath imagePickerController:(UIImagePickerController *)_imagePicker{
    /*
     * @ 在這裡上傳與剪裁選擇好的圖片
     */
    // ... 
}

@end
