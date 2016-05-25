#import "GPUImageGaussianSelectiveBlurFilter.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageTwoInputFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageGaussianSelectiveBlurFragmentShaderString = SHADER_STRING
( 
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; 
 
 uniform lowp float excludeCircleRadius;
 uniform lowp vec2 excludeCirclePoint;
 uniform lowp float excludeBlurSize;
 uniform highp float aspectRatio;

 void main()
 {
//     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
//     lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
//     
//     highp vec2 textureCoordinateToUse = vec2(textureCoordinate2.x, (textureCoordinate2.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
//     highp float distanceFromCenter = distance(excludeCirclePoint, textureCoordinateToUse);
//     
//     gl_FragColor = mix(sharpImageColor, blurredImageColor, smoothstep(excludeCircleRadius - excludeBlurSize, excludeCircleRadius, distanceFromCenter));
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     if(sharpImageColor.r >= 0.2) {
         mediump float bpass;
         //1280*720
         //bpass = min((sharpImageColor.r - blurredImageColor.r)*(sharpImageColor.r - blurredImageColor.r)*0.045455, 1.0);
         //960*540
         bpass = min((sharpImageColor.r - blurredImageColor.r)*(sharpImageColor.r - blurredImageColor.r)*0.055556, 1.0);
         bpass = min((0.5+255.0*(bpass+0.0*bpass*bpass*bpass+bpass)), 1.0);
         gl_FragColor = mix(sharpImageColor, blurredImageColor, 1.0-bpass);
         //gl_FragColor = vec4(bpass, bpass, bpass, 1.0);
     } else {
         gl_FragColor = vec4(sharpImageColor.r, sharpImageColor.g, sharpImageColor.b,1.0);
     }

     mediump float r;
     mediump float g;
     mediump float b;
     r = min((gl_FragColor.r*2.0 - gl_FragColor.r*gl_FragColor.r), 1.0);
     g = min((gl_FragColor.g*2.0 - gl_FragColor.g*gl_FragColor.g), 1.0);
     b = min((gl_FragColor.b*2.0 - gl_FragColor.b*gl_FragColor.b), 1.0);

     r = min(0.95*gl_FragColor.r+0.05*r, 1.0);
     g = min(0.95*gl_FragColor.g+0.05*g, 1.0);
     b = min(0.95*gl_FragColor.b+0.05*b, 1.0);
     gl_FragColor = vec4(r, g, b, 1.0);

 }
);
#else
NSString *const kGPUImageGaussianSelectiveBlurFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float excludeCircleRadius;
 uniform vec2 excludeCirclePoint;
 uniform float excludeBlurSize;
 uniform float aspectRatio;
 
 void main()
 {
//     vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
//     vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
//     
//     vec2 textureCoordinateToUse = vec2(textureCoordinate2.x, (textureCoordinate2.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
//     float distanceFromCenter = distance(excludeCirclePoint, textureCoordinateToUse);
//     
//     gl_FragColor = mix(sharpImageColor, blurredImageColor, smoothstep(excludeCircleRadius - excludeBlurSize, excludeCircleRadius, distanceFromCenter));
     
     vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     if(sharpImageColor.r > 0.372549/*0.372549*/) {
         mediump float bpass;
         bpass = min((sharpImageColor.r - blurredImageColor.r)*(sharpImageColor.r - blurredImageColor.r)*0.045455, 1.0);
         //bpass = min((sharpImageColor.r - blurredImageColor.r)*(sharpImageColor.r - blurredImageColor.r)*0.038462, 1.0);
         bpass = min((0.5+255.0*bpass), 1.0);
         gl_FragColor = mix(sharpImageColor, blurredImageColor, 1.0-bpass);
     } else {
         gl_FragColor = vec4(sharpImageColor.r, sharpImageColor.g, sharpImageColor.b,1.0);
     }
     mediump float r;
     mediump float g;
     mediump float b;
     r = min((gl_FragColor.r*2.0 - gl_FragColor.r*gl_FragColor.r), 1.0);
     g = min((gl_FragColor.g*2.0 - gl_FragColor.g*gl_FragColor.g), 1.0);
     b = min((gl_FragColor.b*2.0 - gl_FragColor.b*gl_FragColor.b), 1.0);
     
     r = min(0.92*gl_FragColor.r+0.08*r, 1.0);
     g = min(0.92*gl_FragColor.g+0.08*g, 1.0);
     b = min(0.92*gl_FragColor.b+0.08*b, 1.0);
     
     gl_FragColor = vec4(r, g, b, 1.0);
     
 }
);
#endif

@implementation GPUImageGaussianSelectiveBlurFilter

@synthesize excludeCirclePoint = _excludeCirclePoint, excludeCircleRadius = _excludeCircleRadius, excludeBlurSize = _excludeBlurSize;
@synthesize blurRadiusInPixels = _blurRadiusInPixels;
@synthesize aspectRatio = _aspectRatio;

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    hasOverriddenAspectRatio = NO;
    
    // First pass: apply a variable Gaussian blur
    blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [self addFilter:blurFilter];
    
    // Second pass: combine the blurred image with the original sharp one
    selectiveFocusFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kGPUImageGaussianSelectiveBlurFragmentShaderString];
    [self addFilter:selectiveFocusFilter];
    
    // Texture location 0 needs to be the sharp image for both the blur and the second stage processing
    [blurFilter addTarget:selectiveFocusFilter atTextureLocation:1];
    
    // To prevent double updating of this filter, disable updates from the sharp image side    
    self.initialFilters = [NSArray arrayWithObjects:blurFilter, selectiveFocusFilter, nil];
    self.terminalFilter = selectiveFocusFilter;
    
    //self.blurRadiusInPixels = 5.0;
    //960*540
    self.blurRadiusInPixels = 9.0;
    //1280*720
    //self.blurRadiusInPixels = 11.0;
    
    self.excludeCircleRadius = 60.0/320.0;
    self.excludeCirclePoint = CGPointMake(0.5f, 0.5f);
    self.excludeBlurSize = 30.0/320.0;
    
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    CGSize oldInputSize = inputTextureSize;
    [super setInputSize:newSize atIndex:textureIndex];
    inputTextureSize = newSize;
    
    if ( (!CGSizeEqualToSize(oldInputSize, inputTextureSize)) && (!hasOverriddenAspectRatio) && (!CGSizeEqualToSize(newSize, CGSizeZero)) )
    {
        _aspectRatio = (inputTextureSize.width / inputTextureSize.height);
        [selectiveFocusFilter setFloat:_aspectRatio forUniformName:@"aspectRatio"];
    }
}

#pragma mark -
#pragma mark Accessors

- (void)setBlurRadiusInPixels:(CGFloat)newValue;
{
    blurFilter.blurRadiusInPixels = newValue;
}

- (CGFloat)blurRadiusInPixels;
{
    return blurFilter.blurRadiusInPixels;
}

- (void)setExcludeCirclePoint:(CGPoint)newValue;
{
    _excludeCirclePoint = newValue;
    [selectiveFocusFilter setPoint:newValue forUniformName:@"excludeCirclePoint"];
}

- (void)setExcludeCircleRadius:(CGFloat)newValue;
{
    _excludeCircleRadius = newValue;
    [selectiveFocusFilter setFloat:newValue forUniformName:@"excludeCircleRadius"];
}

- (void)setExcludeBlurSize:(CGFloat)newValue;
{
    _excludeBlurSize = newValue;
    [selectiveFocusFilter setFloat:newValue forUniformName:@"excludeBlurSize"];
}

- (void)setAspectRatio:(CGFloat)newValue;
{
    hasOverriddenAspectRatio = YES;
    _aspectRatio = newValue;    
    [selectiveFocusFilter setFloat:_aspectRatio forUniformName:@"aspectRatio"];
}

@end
