//
//  PSSignatureView.h
//  qianjituan2.0
//
//  Created by 王留根 on 16/8/11.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GetSignatureImageDelegate <NSObject>

-(void)getSignatureImg:(UIImage*)image;


@end

@interface PSSignatureView : UIView

@property (nonatomic,weak)id<GetSignatureImageDelegate> delegate;

- (void)commonInit;

- (void)clear;

- (void)sure;

@end
