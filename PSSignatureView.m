//
//  PSSignatureView.m
//  qianjituan2.0
//
//  Created by 王留根 on 16/8/11.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

#import "PSSignatureView.h"
#import <QuartzCore/QuartzCore.h>


#define StrWidth 150
#define StrHeight 40


static CGPoint midpoint(CGPoint p0,CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) /2.0,
        (p0.y + p1.y) /2.0
    };
}
@interface PSSignatureView ()

@property(nonatomic,strong)UIBezierPath *path;
@property (nonatomic,assign)CGPoint previousPoint;
@property (nonatomic,assign)CGFloat min;
@property (nonatomic,assign)CGFloat max;
@property (nonatomic,assign)CGRect origRect;
@property (nonatomic,assign)CGFloat origionX;
@property (nonatomic,assign)CGFloat totalWidth;
@property (nonatomic,assign) BOOL  isSure;


@end

@implementation PSSignatureView

- (void)commonInit {
    
    self.path = [[UIBezierPath alloc] init];
    [self.path setLineWidth:2];
    
    self.max = 0;
    self.min = 0;
    // Capture touches
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    //返回该手势包含触碰点的数量（也就是用户用了几个手指进行触碰）。
    pan.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
    
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    //函数返回一个CGPoint类型的值，表示触摸在view这个视图上的位置，这里返回的位置是针对view的坐标系的。调用时传入的view参数为空的话，返回的时触摸点在整个窗口的位置。
    CGPoint currentPoint = [pan locationInView:self];
    
    CGPoint midPoint = midpoint(self.previousPoint, currentPoint);
    //NSLog(@"获取到的触摸点的位置为--currentPoint:%@",NSStringFromCGPoint(currentPoint));
    
    CGFloat viewHeight = self.frame.size.height;
    CGFloat currentY = currentPoint.y;
    //手势所处的状态
    if (pan.state == UIGestureRecognizerStateBegan) {
        //设置初始线段的起点
        [self.path moveToPoint:currentPoint];
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        //画出两点之间的曲线
        [self.path addQuadCurveToPoint:midPoint controlPoint:self.previousPoint];
        
        
    }
    
    if(0 <= currentY && currentY <= viewHeight){
        
        if(self.max == 0 && self.min == 0){
            
            self.max = currentPoint.x;
            self.min = currentPoint.x;
        }
        else{
            
            if(self.max <= currentPoint.x)
            {
                self.max = currentPoint.x;
            }
            if(self.min >= currentPoint.x)
            {
                self.min = currentPoint.x;
            }
        }
        
    }
    
    self.previousPoint = currentPoint;
    
    [self setNeedsDisplay];
}

void ProviderReleaseData (void *info,const void *data,size_t size)
{
    free((void*)data);
}

//绘制曲线
- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor whiteColor];
    [[UIColor blackColor] setStroke];
    [self.path stroke];
    
    self.layer.cornerRadius =5.0;
    self.clipsToBounds =YES;
    self.layer.borderWidth =0.5;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
     //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(!self.isSure){
        
        NSString *str = @"请绘制签名";
        CGContextSetRGBFillColor (context,  200/255, 200/255,200/255, 0.2);//设置填充颜色
        CGRect rect1 = CGRectMake((rect.size.width -StrWidth)/2, (rect.size.height -StrHeight)/2-5,StrWidth, StrHeight);
        self.origionX = rect1.origin.x;
        self.totalWidth = rect1.origin.x+StrWidth;
        
        UIFont  *font = [UIFont systemFontOfSize:25];//设置字体
        [str drawInRect:rect1 withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[[PSTheme sharedInstance] colorWithHex:0xdddddd]}];
    }else{
        
        self.isSure = NO;
    }
    
    
}

-(void)handelSingleTap:(UITapGestureRecognizer*)tap{
    
    return [self imageRepresentation];
    
}
//只截取签名部分图片
- (UIImage *)cutImage:(UIImage *)image
{
    CGRect rect ;
    //签名事件没有发生
    if(self.min == 0 && self.max == 0)
    {
        rect =CGRectMake(0,0, 0, 0);
    }
    else//签名发生
    {
        rect =CGRectMake(self.min-3,2, self.max-self.min+6,self.frame.size.height-3);
    }
    //从原图片中取出小图
    CGImageRef imageRef =CGImageCreateWithImageInRect([image CGImage], rect);
    //转化成图片
    UIImage * img = [UIImage imageWithCGImage:imageRef];
    
    //UIImage *lastImage = [self addText:img text:self.showMessage];
    
    [self setNeedsDisplay];
    return img;
}

- (void)clear
{
    self.path = [[UIBezierPath alloc] init];
    [self.path setLineWidth:2];
    
    self.max = 0;
    self.min = 0;
    
    [self setNeedsDisplay];
}
- (void)sure
{
    //没有签名发生时
    if(self.max == 0 && self.min == 0)
    {
        self.max = 0;
        self.min = 0;
    }
    

    self.isSure = YES;
    [self setNeedsDisplay];
    return [self imageRepresentation];
}
-(void) imageRepresentation {
    
//    if( UIGraphicsBeginImageContextWithOptions != nil)
//    {
    //size——同UIGraphicsBeginImageContext的CGSizeMake(240，240),opaque—透明开关，如果图形完全不用透明，设置为YES以优化位图的存储。scale—–缩放的比例,开启上下文
    // //该函数会自动创建一个context，并把它push到上下文栈顶，坐标系也经处理和UIKit的坐标系相同
     UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO, [UIScreen mainScreen].scale);
//    }else {
//        UIGraphicsBeginImageContext(self.bounds.size);
//        
//    }
    //UIView自带提供的在drawRect:方法中通过UIGraphicsGetCurrentContext获取，
   //把当前的整个画面导入到context中，然后通过context输出UIImage，这样就可以把整个屏幕转化为图片
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    ////把当前context的内容输出成一个UIImage图片
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    //结束
    UIGraphicsEndImageContext();
    
    image = [self imageBlackToTransparent:image];
    
    NSLog(@"width:%f,height:%f",image.size.width,image.size.height);
    //剪切图片
    UIImage *img = [self cutImage:image];
    
    [self.delegate getSignatureImg: img];
    
}
//转化透明背景
- (UIImage*) imageBlackToTransparent:(UIImage*) image
{
    // 分配内存
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    //创建GRB颜色空间,使用完毕后要释放颜色空间：
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    /**
     当你调用这个函数的时候，Quartz创建一个位图绘制环境，也就是位图上下文。当你向上下文中绘制信息时，Quartz把你要绘制的信息作为位图数据绘制到指定的内存块。一个新的位图上下文的像素格式由三个参数决定：每个组件的位数，颜色空间，alpha选项。alpha值决定了绘制像素的透明性。
     
     data                                    指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
     width                                  bitmap的宽度,单位为像素
     height                                bitmap的高度,单位为像素
     bitsPerComponent        内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
     bytesPerRow                  bitmap的每一行在内存所占的比特数
     colorspace                      bitmap上下文使用的颜色空间。
     bitmapInfo                       指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
    CGContextRef context = CGBitmapContextCreate(<#void * _Nullable data#>, <#size_t width#>, <#size_t height#>, <#size_t bitsPerComponent#>, <#size_t bytesPerRow#>, <#CGColorSpaceRef  _Nullable space#>, <#uint32_t bitmapInfo#>)
     */

    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    //在上下文中绘制图形
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    // 遍历像素，透明背景
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i =0; i < pixelNum; i++, pCurPtr++)
    {
        //        if ((*pCurPtr & 0xFFFFFF00) == 0)    //将黑色变成透明
        if (*pCurPtr == 0xffffff)
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] =0;
        }

    }
    
    // 将内存转成image//将Data转换为Quartz直接访问的数据类型，目测其逻辑为制定数据内容，给定起始地址、长度等信息。
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight,ProviderReleaseData);
    /**
     CGImageRef CGImageCreate (
     size_t width, //图片的宽度
     size_t height, //图片的高度
     size_t bitsPerComponent,  //图片每个颜色的bits，比如rgb颜色空间，有可能是5 或者 8 ==
     size_t bitsPerPixel,  //每一个像素占用的buts，15 位24位 32位等等
     size_t bytesPerRow, //每一行占用多少bytes 注意是bytes不是bits  1byte ＝ 8bit
     CGColorSpaceRef colorspace,  //颜色空间，比如rgb
     CGBitmapInfo bitmapInfo,  //layout ，像素中bit的布局， 是rgba还是 argb，＝＝
     CGDataProviderRef provider,  //数据源提供者，url或者内存＝＝
     const CGFloat decode[],  //一个解码数组
     bool shouldInterpolate,  //抗锯齿参数
     CGColorRenderingIntent intent
     //图片渲染相关参数
     );
     */
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8,32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true,kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
    
    CGContextRelease(context);
    //释放颜色空间
    CGColorSpaceRelease(colorSpace);
    // free(rgbImageBuf) 创建dataProvider时已提供释放函数，这里不用free
    
    return resultUIImage;
}
//压缩图片，这是重新规划大小，展示没有做处理，未调用
- (UIImage *)scaleToSize:(UIImage *)img {
    
    CGRect rect ;

    rect =CGRectMake(0,0, img.size.width,self.frame.size.height);
        

    CGSize size = rect.size;
    
    UIGraphicsBeginImageContext(size);
    
    [img drawInRect:rect];
    
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //存入相册
    UIImageWriteToSavedPhotosAlbum(scaledImage,nil, nil, nil);
    
    [self setNeedsDisplay];
    
    return scaledImage;
}


@end
