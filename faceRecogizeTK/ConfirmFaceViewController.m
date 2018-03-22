//
//  ConfirmFaceViewController.m
//  faceRecogizeTK
//
//  Created by keenteam on 2018/3/22.
//  Copyright © 2018年 keenteam. All rights reserved.
//

#import "ConfirmFaceViewController.h"
#import "UIImage+Extensions.h"
#import "UIImage+compress.h"
#import "DemoPreDefine.h"
#import "PermissionDetector.h"
#import "iflyMSC/IFlyFaceSDK.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "IFlyFaceResultKeys.h"
#import "HHControl.h"
@interface ConfirmFaceViewController ()<
IFlyFaceRequestDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIActionSheetDelegate,
UIPopoverControllerDelegate
>
{
    UIToolbar* tBar;
    UIButton * leftBtn;
}
@property (nonatomic , strong)IFlyFaceRequest * iFlySpFaceRequest;
@property (nonatomic , strong)UIActivityIndicatorView * activityIndicator;
@property (nonatomic , strong)UIImageView * imgToUse;
@property (nonatomic , strong)CALayer *imgToUseCoverLayer;
@property (nonatomic , strong)NSString *resultStings;
@property (nonatomic,retain) UIPopoverController *popover;

@end

@implementation ConfirmFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"KT人脸检测实例";
    [self createNavigationBackImage];
    [self createLeftItemBar];
    [self initiFlySpFaceRequest];
    [self createToolBar];
}

- (void)createToolBar{
    
    //toolBar
    tBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-108, self.view.frame.size.width, 44)];
    [self.view addSubview:tBar];
    
    UIBarButtonItem * imgSelectBtn = [[UIBarButtonItem alloc]initWithTitle:@"选择图片" style:UIBarButtonItemStylePlain target:self action:@selector(btnSelectImageClicked:)];
    
    UIBarButtonItem * itemButtonEmpty = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UIBarButtonItem * funcSelectBtn = [[UIBarButtonItem alloc]initWithTitle:@"识别图片" style:UIBarButtonItemStylePlain target:self action:@selector(btnRecognizeImageClicked:)];
    
    tBar.items=@[imgSelectBtn,itemButtonEmpty,funcSelectBtn];
    
}

/**选取功能*/
- (void)btnRecognizeImageClicked:(UIBarButtonItem *)sender{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"接口功能示例"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  @"注册",
                                  @"验证",
                                  @"人脸检测",
                                  @"人脸关键点检测",
                                  nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.alpha = 1.0f;
    actionSheet.tag = 2;
    UIView *bgView=[[UIView alloc] initWithFrame:actionSheet.frame];
    bgView.backgroundColor = [UIColor lightGrayColor];
    [actionSheet addSubview:bgView];
    bgView=nil;
    
    [actionSheet showInView:self.view];
    actionSheet=nil;
    
}

/**选取图片*/
- (void)btnSelectImageClicked:(UIBarButtonItem *)sender{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"图片获取方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"摄相机", @"图片库", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.alpha = 1.f;
    actionSheet.tag = 1;
    
    UIView *bgView=[[UIView alloc] initWithFrame:actionSheet.frame];
    bgView.backgroundColor = [UIColor lightGrayColor];
    [actionSheet addSubview:bgView];
    bgView=nil;
    
    [actionSheet showInView:self.view];
    actionSheet=nil;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (actionSheet.tag)
    {
        case 1://选择图片
            switch (buttonIndex)
        {
                
            case 0:
            {
                [self btnPhotoClicked:nil];
            }
                break;
            case 1:
            {
                [self btnExploerClicked:nil];
            }
                break;
        }
            break;
        case 2://选择功能
            switch (buttonIndex)
        {
                
            case 0:
            {
                [self btnRegClicked:nil];
                
            }
                break;
            case 1:
            {
                [self btnVerifyClicked:nil];
            }
                break;
            case 2:
            {
                [self btnDetectClicked:nil];
            }
                break;
            case 3:
            {
                [self btnAlignClicked:nil];
            }
                break;
        }
            break;
    }
}

/**相机拍照功能*/
- (void)btnPhotoClicked:(id)sender {
    
    if(![PermissionDetector isCapturePermissionGranted]){
        NSString* info=@"没有相机权限";
        [self showAlert:info];
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
        picker.mediaTypes = @[(NSString*)kUTTypeImage];
        picker.allowsEditing = NO;//设置可编辑
        picker.delegate = self;
        
        [self performSelector:@selector(presentImagePicker:) withObject:picker afterDelay:1.0f];
        
    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;

    }
}

/**选取相册功能*/
- (void)btnExploerClicked:(id)sender {
    
    if(![PermissionDetector isAssetsLibraryPermissionGranted]){
        NSString* info=@"没有相册权限";
        [self showAlert:info];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    if([UIImagePickerController isSourceTypeAvailable: picker.sourceType ]) {
        picker.mediaTypes = @[(NSString*)kUTTypeImage];
        picker.delegate = self;
        picker.allowsEditing = NO;
    }
    
    [self performSelector:@selector(presentImagePicker:) withObject:picker afterDelay:1.0f];
}

/**人脸注册功能*/
- (void)btnRegClicked:(id)sender {
    self.resultStings=nil;
    self.resultStings=[[NSString alloc] init];
    
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
   
    
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_REG] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:@"auth_id"];
    [self.iFlySpFaceRequest setParameter:@"del" forKey:@"property"];
    NSData* imgData=[_imgToUse.image compressedData];
    [self.iFlySpFaceRequest sendRequest:imgData];
    
}

/**人脸验证功能*/
- (void)btnVerifyClicked:(id)sender {
    
    self.resultStings=nil;
    self.resultStings=[[NSString alloc] init];
    
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
   
    
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_VERIFY] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:@"auth_id"];
    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
    NSString* gid=[userDefaults objectForKey:KCIFlyFaceResultGID];
    if(!gid){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"结果" message:@"请先注册，或在设置中输入已注册的gid" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        [_activityIndicator stopAnimating];
        [_activityIndicator setHidden:YES];
      
        return;
    }
    [self.iFlySpFaceRequest setParameter:gid forKey:[IFlySpeechConstant FACE_GID]];
    [self.iFlySpFaceRequest setParameter:@"2000" forKey:@"wait_time"];
    NSData* imgData=[_imgToUse.image compressedData];
    [self.iFlySpFaceRequest sendRequest:imgData];
    
}

/**人脸检测功能*/
- (void)btnDetectClicked:(id)sender {
    
    self.resultStings=nil;
    self.resultStings=[[NSString alloc] init];
    
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
    
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_DETECT] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    NSData* imgData=[_imgToUse.image compressedData];
    [self.iFlySpFaceRequest sendRequest:imgData];
    
}

/**人脸关键点检测功能*/
- (void)btnAlignClicked:(id)sender {
    
    self.resultStings=nil;
    self.resultStings=[[NSString alloc] init];
    
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
   
    
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_ALIGN] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    NSData* imgData=[_imgToUse.image compressedData];
    [self.iFlySpFaceRequest sendRequest:imgData];
    
}

/** 初始化指示器 */
- (void)initiFlySpFaceRequest{
    
    self.iFlySpFaceRequest=[IFlyFaceRequest sharedInstance];
    [self.iFlySpFaceRequest setDelegate:self];
    [self.view addSubview:self.imgToUse];
    self.imgToUse.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator setHidden:YES];
    CGRect rect= self.activityIndicator.frame;
    self.activityIndicator.frame=CGRectMake(rect.origin.x-1.5*rect.size.width, rect.origin.y-1.5*rect.size.height, 3*rect.size.width, 3*rect.size.height);
    self.resultStings=[[NSString alloc] init];
    
    
}

/** 创建左导航 */
- (void)createNavigationBackImage{
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"ac_perfectinfo_btbg"] forBarMetrics:UIBarMetricsDefault];
}

/** 创建左导航按钮 */
- (void)createLeftItemBar{
    
    leftBtn = [HHControl backItemWithimage:[UIImage imageNamed:@"navigationButtonReturnClick"] highImage:[UIImage imageNamed:@"navigationButtonReturn"]  target:self action:@selector(clickLeftBtn) title:@"Back"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
   
}

/** 点击返回按钮 */
- (void)clickLeftBtn{
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (UIImageView *)imgToUse{
    
    if (!_imgToUse) {
        _imgToUse = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-120)];
    }
    
    return _imgToUse;
}

-(void)showAlert:(NSString*)info{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:info delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}

-(void)showResultInfo:(NSString*)resultInfo{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"结果" message:resultInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}


#pragma mark - IFlyFaceRequestDelegate
/**
 * 消息回调
 * @param eventType 消息类型
 * @param params 消息数据对象
 */
- (void) onEvent:(int) eventType WithBundle:(NSString*) params{
    NSLog(@"onEvent | params:%@",params);
}

/**
 * 数据回调，可能调用多次，也可能一次不调用
 */
- (void) onData:(NSData* )data{
    
    NSLog(@"onData | ");
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"result:%@",result);
    
    if (result) {
        self.resultStings=[self.resultStings stringByAppendingString:result];
    }
    
}

/**
 * 结束回调，没有错误时，error为null
 * @param error 错误类型
 */
- (void) onCompleted:(IFlySpeechError*) error{
    
    [_activityIndicator stopAnimating];
    [_activityIndicator setHidden:YES];

    NSString* errorInfo=[NSString stringWithFormat:@"错误码：%d\n 错误描述：%@",[error errorCode],[error errorDesc]];
    if(0!=[error errorCode]){
        [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:errorInfo waitUntilDone:NO];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateFaceImage:self.resultStings];
        });
    }
}

#pragma mark - Perform results On UI

-(void)updateFaceImage:(NSString*)result{
    
    NSError* error;
    NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
    
    if(dic){
        NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
        
        //注册
        if([strSessionType isEqualToString:KCIFlyFaceResultReg]){
            [self praseRegResult:result];
        }
        
        //验证
        if([strSessionType isEqualToString:KCIFlyFaceResultVerify]){
            [self praseVerifyResult:result];
        }
        
        //检测
        if([strSessionType isEqualToString:KCIFlyFaceResultDetect]){
            [self praseDetectResult:result];
        }
        
        //关键点
        if([strSessionType isEqualToString:KCIFlyFaceResultAlign]){
            [self praseAlignResult:result];
        }
        
    }
}


#pragma mark - Data Parser

-(void)praseRegResult:(NSString*)result{
    NSString *resultInfo = @"";
    NSString *resultInfoForLabel = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            //注册
            if([strSessionType isEqualToString:KCIFlyFaceResultReg]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"注册错误\n错误码：%@",ret];
                }else{
                    if(rst && [rst isEqualToString:KCIFlyFaceResultSuccess]){
                        NSString* gid=[dic objectForKey:KCIFlyFaceResultGID];
                        resultInfo=[resultInfo stringByAppendingString:@"检测到人脸\n注册成功！"];
                        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                        [defaults setObject:gid forKey:KCIFlyFaceResultGID];
                        resultInfoForLabel=[resultInfoForLabel stringByAppendingFormat:@"gid:%@",gid];
                    }else{
                        resultInfo=[resultInfo stringByAppendingString:@"未检测到人脸\n注册失败！"];
                    }
                }
            }
            
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
          
            [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    
    
}

-(void)praseVerifyResult:(NSString*)result{
    NSString *resultInfo = @"";
    NSString *resultInfoForLabel = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            if([strSessionType isEqualToString:KCIFlyFaceResultVerify]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"验证错误\n错误码：%@",ret];
                }else{
                    
                    if([rst isEqualToString:KCIFlyFaceResultSuccess]){
                        resultInfo=[resultInfo stringByAppendingString:@"检测到人脸\n"];
                    }else{
                        resultInfo=[resultInfo stringByAppendingString:@"未检测到人脸\n"];
                    }
                    NSString* verf=[dic objectForKey:KCIFlyFaceResultVerf];
                    NSString* score=[dic objectForKey:KCIFlyFaceResultScore];
                    if([verf boolValue]){
                        resultInfoForLabel=[resultInfoForLabel stringByAppendingFormat:@"score:%@\n",score];
                        resultInfo=[resultInfo stringByAppendingString:@"验证结果:验证成功!"];
                    }else{
                        NSUserDefaults* defaults=[NSUserDefaults standardUserDefaults];
                        NSString* gid=[defaults objectForKey:KCIFlyFaceResultGID];
                        resultInfoForLabel=[resultInfoForLabel stringByAppendingFormat:@"last reg gid:%@\n",gid];
                        resultInfo=[resultInfo stringByAppendingString:@"验证结果:验证失败!"];
                    }
                }
                
            }
            
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
          
            
            if([resultInfo length]<1){
                resultInfo=@"结果异常";
            }
            
            [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
        
    }
    
    
}

-(void)praseDetectResult:(NSString*)result{
    NSString *resultInfo = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            //检测
            if([strSessionType isEqualToString:KCIFlyFaceResultDetect]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"检测人脸错误\n错误码：%@",ret];
                }else{
                    resultInfo=[resultInfo stringByAppendingString:[rst isEqualToString:KCIFlyFaceResultSuccess]?@"检测到人脸轮廓":@"未检测到人脸轮廓"];
                }
                
                
                //绘图
                if(_imgToUseCoverLayer){
                    _imgToUseCoverLayer.sublayers=nil;
                    [_imgToUseCoverLayer removeFromSuperlayer];
                    _imgToUseCoverLayer=nil;
                }
                _imgToUseCoverLayer = [[CALayer alloc] init];
                
                
                NSArray* faceArray=[dic objectForKey:KCIFlyFaceResultFace];
                
                for(id faceInArr in faceArray){
                    
                    CALayer* layer= [[CALayer alloc] init];
                    layer.borderWidth = 2.0f;
                    [layer setCornerRadius:2.0f];
                    
                    float image_x, image_y, image_width, image_height;
                    if(_imgToUse.image.size.width/_imgToUse.image.size.height > _imgToUse.frame.size.width/_imgToUse.frame.size.height){
                        image_width = _imgToUse.frame.size.width;
                        image_height = image_width/_imgToUse.image.size.width * _imgToUse.image.size.height;
                        image_x = 0;
                        image_y = (_imgToUse.frame.size.height - image_height)/2;
                        
                    }else if(_imgToUse.image.size.width/_imgToUse.image.size.height < _imgToUse.frame.size.width/_imgToUse.frame.size.height)
                    {
                        image_height = _imgToUse.frame.size.height;
                        image_width = image_height/_imgToUse.image.size.height * _imgToUse.image.size.width;
                        image_y = 0;
                        image_x = (_imgToUse.frame.size.width - image_width)/2;
                        
                    }else{
                        image_x = 0;
                        image_y = 0;
                        image_width = _imgToUse.frame.size.width;
                        image_height = _imgToUse.frame.size.height;
                    }
                    
                    CGFloat resize_scale = image_width/_imgToUse.image.size.width;
                    //
                    if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                        
                        id posDic=[faceInArr objectForKey:KCIFlyFaceResultPosition];
                        if([posDic isKindOfClass:[NSDictionary class]]){
                            CGFloat bottom =[[posDic objectForKey:KCIFlyFaceResultBottom] floatValue];
                            CGFloat top=[[posDic objectForKey:KCIFlyFaceResultTop] floatValue];
                            CGFloat left=[[posDic objectForKey:KCIFlyFaceResultLeft] floatValue];
                            CGFloat right=[[posDic objectForKey:KCIFlyFaceResultRight] floatValue];
                            
                            float x = left;
                            float y = top;
                            float width = right- left;
                            float height = bottom- top;
                            
                            CGRect innerRect = CGRectMake( resize_scale*x+image_x, resize_scale*y+image_y, resize_scale*width, resize_scale*height);
                            
                            [layer setFrame:innerRect];
                            layer.borderColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor];
                            
                        }
                        
                        id attrDic=[faceInArr objectForKey:KCIFlyFaceResultAttribute];
                        if([attrDic isKindOfClass:[NSDictionary class]]){
                            id poseDic=[attrDic objectForKey:KCIFlyFaceResultPose];
                            id pit=[poseDic objectForKey:KCIFlyFaceResultPitch];
                            
                            CATextLayer *label = [[CATextLayer alloc] init];
                            [label setFontSize:14];
                            [label setString:[@"" stringByAppendingFormat:@"%@", pit]];
                            [label setAlignmentMode:kCAAlignmentCenter];
                            [label setForegroundColor:layer.borderColor];
                            [label setFrame:CGRectMake(0, layer.frame.size.height, layer.frame.size.width, 25)];
                            
                            [layer addSublayer:label];
                        }
                    }
                    [_imgToUseCoverLayer addSublayer:layer];
                    
                }
                
                
                [self.imgToUse.layer addSublayer:_imgToUseCoverLayer];
            }
            
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
            
            
            [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    
}

-(void)praseAlignResult:(NSString*)result{
    NSString *resultInfo = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            //关键点
            if([strSessionType isEqualToString:KCIFlyFaceResultAlign]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"检测关键点错误\n错误码：%@",ret];
                }else{
                    resultInfo=[resultInfo stringByAppendingString:[rst isEqualToString:@"success"]?@"检测到人脸关键点":@"未检测到人脸关键点"];
                }
                
                
                //绘图
                if(_imgToUseCoverLayer){
                    _imgToUseCoverLayer.sublayers=nil;
                    [_imgToUseCoverLayer removeFromSuperlayer];
                    _imgToUseCoverLayer=nil;
                }
                _imgToUseCoverLayer = [[CALayer alloc] init];
                
                float image_x, image_y, image_width, image_height;
                if(_imgToUse.image.size.width/_imgToUse.image.size.height > _imgToUse.frame.size.width/_imgToUse.frame.size.height){
                    image_width = _imgToUse.frame.size.width;
                    image_height = image_width/_imgToUse.image.size.width * _imgToUse.image.size.height;
                    image_x = 0;
                    image_y = (_imgToUse.frame.size.height - image_height)/2;
                    
                }else if(_imgToUse.image.size.width/_imgToUse.image.size.height < _imgToUse.frame.size.width/_imgToUse.frame.size.height)
                {
                    image_height = _imgToUse.frame.size.height;
                    image_width = image_height/_imgToUse.image.size.height * _imgToUse.image.size.width;
                    image_y = 0;
                    image_x = (_imgToUse.frame.size.width - image_width)/2;
                    
                }else{
                    image_x = 0;
                    image_y = 0;
                    image_width = _imgToUse.frame.size.width;
                    image_height = _imgToUse.frame.size.height;
                }
                
                CGFloat resize_scale = image_width/_imgToUse.image.size.width;
                
                NSArray* resultArray=[dic objectForKey:KCIFlyFaceResultResult];
                for (id anRst in resultArray) {
                    if(anRst && [anRst isKindOfClass:[NSDictionary class]]){
                        NSDictionary* landMarkDic=[anRst objectForKey:KCIFlyFaceResultLandmark];
                        NSEnumerator* keys=[landMarkDic keyEnumerator];
                        for(id key in keys){
                            id attr=[landMarkDic objectForKey:key];
                            if(attr && [attr isKindOfClass:[NSDictionary class]]){
                                id attr=[landMarkDic objectForKey:key];
                                CGFloat x=[[attr objectForKey:KCIFlyFaceResultPointX] floatValue];
                                CGFloat y=[[attr objectForKey:KCIFlyFaceResultPointY] floatValue];
                                
                                CALayer* layer= [[CALayer alloc] init];
                                NSLog(@"resize_scale:%f",resize_scale);
                                CGFloat radius=5.0f*resize_scale;
                                //关键点大小限制
                                if(radius>10){
                                    radius=10;
                                }
                                [layer setCornerRadius:radius];
                                CGRect innerRect = CGRectMake( resize_scale*x+image_x-radius/2, resize_scale*y+image_y-radius/2, radius, radius);
                                [layer setFrame:innerRect];
                                layer.backgroundColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor];
                                
                                [_imgToUseCoverLayer addSublayer:layer];
                                
                                
                            }
                        }
                    }
                }
                
                [self.imgToUse.layer addSublayer:_imgToUseCoverLayer];
                
            }
            
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
            
            [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
        
    }
    
}


#pragma mark - button event
- (void)presentImagePicker:(UIImagePickerController* )picker{
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
    
    UIImage* image=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    _imgToUse.image = [[image fixOrientation] compressedImage];//将图片压缩以上传服务器
    
    
    if(self.popover){
        [self.popover dismissPopoverAnimated:YES];
        self.popover=nil;
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
   
    
    if(self.popover){
        [self.popover dismissPopoverAnimated:YES];
        self.popover=nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
