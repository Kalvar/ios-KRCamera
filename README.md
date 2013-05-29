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
        /*
         * @ 如果要用 presentViewController 的模式啟動相機，就不需要在 viewDidLoad 裡執行 wantToFullScreen 方法。
         */
        //[self presentViewController:self._krCamera animated:YES completion:nil];
        if( [self._krCamera isIpadDevice] )
        {
            [self._krCamera startCamera];
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
             * @ 在這裡可自訂義 Camera 的呎吋與出現位置
             */
            //If you wanna customize camera displays frame with iPhone 5.
            //Then you can use sizetoFistIphone5 to open autolayout setting.
            self._krCamera.sizeToFitIphone5 = YES;
            [self._krCamera.view setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
            [self._krCamera startCamera];
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

KRCamera now is V1.2 Released.

## License

KRCamera is available under the MIT license ( or Whatever you wanna do ). See the LICENSE file for more info.
