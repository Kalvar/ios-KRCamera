## Supports

KRCamera supports ARC ( Automatic Reference Counting ). If you received a memory warning message, that may be an iOS Version bugs happened.

## How To Get Started

``` objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];
	_krCamera = [[KRCamera alloc] initWithDelegate:self];
    
}

#pragma KRCameraDelegate
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
-(void)krCameraDidCancel:(UIImagePickerController *)_imagePicker
{
    
}

-(void)krCameraDidFinishPickingMediaWithInfo:(NSDictionary *)_infos imagePickerController:(UIImagePickerController *)_imagePicker
{
    
}

-(void)krCameraDidFinishPickingImage:(UIImage *)_image imagePath:(NSString *)_imagePath metadata:(NSDictionary *)_metadatas imagePickerController:(UIImagePickerController *)_imagePicker
{
    
    //NSLog(@"meta : %@", _metadatas);
    
}

-(void)krCameraDidFinishPickingImage:(UIImage *)_image imagePath:(NSString *)_imagePath imagePickerController:(UIImagePickerController *)_imagePicker
{
    //... Do Something ... 
}
```

## Version

KRCamera now is V0.5 beta.

## License

KRCamera is available under the MIT license ( or Whatever you wanna do ). See the LICENSE file for more info.
