//
//  PSAutographViewController.m
//  qianjituan2.0
//
//  Created by 王留根 on 16/8/11.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

#import "PSAutographViewController.h"
#import "PSSignatureView.h"

@interface PSAutographViewController ()<GetSignatureImageDelegate>

@property (nonatomic,strong) PSSignatureView * signatureView;

@end

@implementation PSAutographViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"合同签名";
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.pictureUrl.length > 1) {
        self.title = @"查看签名";
        [self showPicture];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
           [self setupView];
        });
    
    }
    
    
    // Do any additional setup after loading the view.
}

-(void)showPicture {
    UIImageView * showPic = [UIImageView new];
    [self.view addSubview:showPic];
    [YLUtils judgeCacheRefreshWithUrlString:self.pictureUrl imageView:showPic];
    [showPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
}

-(void)setupView {
    self.signatureView = [PSSignatureView new];
    self.signatureView.delegate = self;
    [self.signatureView commonInit];
    [self.view addSubview:self.signatureView];
    [self.signatureView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(1);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(-42);
    }];
    self.signatureView.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *reSignatureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:reSignatureButton];
    [reSignatureButton setTitle:@"清除"forState:UIControlStateNormal];
    [reSignatureButton setTitleColor:[UIColor colorWithHue:72 saturation:106 brightness:123 alpha:0.7] forState:UIControlStateNormal];
    [reSignatureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.signatureView.mas_bottom).offset(1);
        make.right.equalTo(self.signatureView.mas_centerX).offset(-20);
        make.left.equalTo(self.signatureView.mas_left).offset(20);
        make.height.equalTo(@(40));
    }];
    [reSignatureButton setFrame:CGRectMake(20,self.signatureView.frame.origin.y+120,130, 40)];
    reSignatureButton.layer.cornerRadius =5.0;
    reSignatureButton.clipsToBounds =YES;
    reSignatureButton.layer.borderWidth =1.0;
    reSignatureButton.titleLabel.font = [UIFont systemFontOfSize:17];
    reSignatureButton.layer.borderColor = [[UIColor blackColor] CGColor];
    [reSignatureButton addTarget:self action:@selector(reSignatureButtonClear:)forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:sureButton];
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.signatureView.mas_bottom).offset(1);
        make.left.equalTo(self.view.mas_centerX).offset(20);
        make.right.equalTo(self.signatureView.mas_right).offset(-20);
        make.height.equalTo(@(40));
    }];
    [sureButton setTitle:@"签好了"forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureButton.titleLabel.font = [UIFont systemFontOfSize:17];
    sureButton.backgroundColor = [UIColor blueColor];
    sureButton.layer.cornerRadius =5.0;
    sureButton.clipsToBounds = YES;
    [sureButton addTarget:self action:@selector(sureButtonAction:)forControlEvents:UIControlEventTouchUpInside];
}

- (void)sureButtonAction:(UIButton *)sender
{
        [self.signatureView sure];
    
}

- (void)reSignatureButtonClear:(UIButton *)sender
{
        NSLog(@"重签");
        [self.signatureView clear];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark- 手绘签名回调

-(void)getSignatureImg:(UIImage *)image {
    if(image)
    {
        NSLog(@"haveImage");
        NSLog(@"self.width:%f,self.height:%f",image.size.width,image.size.height);
        
        // 图片上传接口
        [[PSHintView shareHintView] loadAnimationShow];
        [NetWorkManager uploadImageWithImage:image success:^(id  _Nullable responseObject) {
            [[PSHintView shareHintView] removeLoadAnimation];
            [PSHintView showMessageOnThisPage:@"签名成功"];
            
            NSString *strUrl = responseObject[PSNetworkKey_Data];
            if (self.signatureFishBlock) {
                self.signatureFishBlock(strUrl);
            }
            [self.navigationController popViewControllerAnimated:YES];
            
           // NSLog(@"回传签名地址%@",strUrl);
        } failure:^(id  _Nullable responseObject) {
            [[PSHintView shareHintView] removeLoadAnimation];
            [PSHintView showMessageOnThisPage:@"签名失败"];
        } error:^(NSError * _Nonnull error) {
            [[PSHintView shareHintView] removeLoadAnimation];
        }];


    }
    else
    {
        NSLog(@"NoImage");
        
    }
}
//- (NSString *)cacheCapacity:(UIImage *)image {
//
////    NSUInteger s1 = UIImagePNGRepresentation(self.saveImage).length;         //992400
////    
////    NSUInteger s2 = UIImageJPEGRepresentation(self.saveImage, 1).length;     //923162
//    
//    NSUInteger s3  = CGImageGetHeight(image.CGImage) * CGImageGetBytesPerRow(image.CGImage);
//    NSString *str;
//    CGFloat capacity = s3;
//    
//
//    if (capacity < (K)) {
//        str = [NSString stringWithFormat:@"%.01fB", capacity];
//    }else if (capacity > (K) && capacity <(M)) {
//        str = [NSString stringWithFormat:@"%.01fKB", capacity/(K)];
//    }else if (capacity >(M) && capacity <(G)) {
//        str = [NSString stringWithFormat:@"%.01fMB", capacity/(M)];
//    }else {
//        str = [NSString stringWithFormat:@"%.01fG", capacity/(G)];
//    }
//    
//    return str;
//}

#pragma mark -生命周期相关

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    
    self.navigationController.view.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT);
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    
}

-(void)viewWillDisappear:(BOOL)animated {
    //暂时放这里
    self.navigationController.view.transform = CGAffineTransformIdentity;
    
    self.navigationController.view.frame = [UIScreen mainScreen].bounds;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}

































@end
