## Supports

KRCamera supports ARC ( Automatic Reference Counting ). If you received a memory warning message, that may be an iOS Version bugs happened.

## How To Get Started

``` objective-c
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

#pragma KRCameraDelegate
/*
 * @ 上傳圖片
 */
-(IBAction)takePicture:(id)sender
{
    self._krCamera.isOpenVideo             = NO;
    self._krCamera.sourceMode              = KRCameraModesForCamera;
    self._krCamera.autoDismissPresent      = NO;
    self._krCamera.autoRemoveFromSuperview = YES;
    self._krCamera.displaysCameraControls  = YES;
    [self._krCamera startCamera];
    /*
     * @ 如果要用 presentViewController 的模式啟動相機，就不需要在 viewDidLoad 裡執行 wantToFullScreen 方法。
     */
    //[self presentViewController:self._krCamera animated:YES completion:nil];
    /*
     * @ 如果要用 addSubview 的模式啟動相機，就要先在 viewDidLoad 裡執行 wantToFullScreen 方法先隱藏狀態列。
     */
    [self.view addSubview:self._krCamera.view];
}

-(IBAction)choosePicture:(id)sender
{
    self._krCamera.isOpenVideo             = NO;
    self._krCamera.sourceMode              = KRCameraModesForSelectAlbum;
    self._krCamera.autoDismissPresent      = YES;
    self._krCamera.autoRemoveFromSuperview = NO;
    [self._krCamera startChoose];
    [self presentViewController:self._krCamera animated:YES completion:nil];
}

#pragma KRCameraDelegate
-(void)krCameraDidCancel:(UIImagePickerController *)_imagePicker
{
    
}

-(void)krCameraDidFinishPickingMediaWithInfo:(NSDictionary *)_infos imagePickerController:(UIImagePickerController *)_imagePicker
{
    
}

-(void)krCameraDidFinishPickingImage:(UIImage *)_image imagePath:(NSString *)_imagePath metadata:(NSDictionary *)_metadatas imagePickerController:(UIImagePickerController *)_imagePicker
{
   
}

-(void)krCameraDidFinishPickingImage:(UIImage *)_image imagePath:(NSString *)_imagePath imagePickerController:(UIImagePickerController *)_imagePicker
{
    
}

-(void)krCameraDidFinishPickingVideoPath:(NSString *)_videoPath imagePickerController:(UIImagePickerController *)_imagePicker
{
    
}
```

## Version

KRCamera now is V1.1 Released.

## License

KRCamera is available under the MIT license ( or Whatever you wanna do ). See the LICENSE file for more info.
