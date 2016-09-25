//
//  PSAutographViewController.h
//  qianjituan2.0
//
//  Created by 王留根 on 16/8/11.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSAutographViewController : UIViewController

@property(nonatomic,strong)NSString *pictureUrl;

/** 签名完成回调 */
@property (nonatomic, copy) void (^signatureFishBlock)(NSString * url);

@end
