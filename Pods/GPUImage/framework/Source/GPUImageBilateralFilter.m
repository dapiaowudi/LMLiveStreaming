#import "GPUImageBilateralFilter.h"

NSString *const kGPUImageBilateralBlurVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 const int GAUSSIAN_SAMPLES = 9;
 
 uniform float texelWidthOffset;
 uniform float texelHeightOffset;
 
 varying vec2 textureCoordinate;
 varying vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     
     // Calculate the positions for the blur
     int multiplier = 0;
     vec2 blurStep;
     vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
     
     for (int i = 0; i < GAUSSIAN_SAMPLES; i++)
     {
         multiplier = (i - ((GAUSSIAN_SAMPLES - 1) / 2));
         // Blur in x (horizontal)
         blurStep = float(multiplier) * singleStepOffset;
         blurCoordinates[i] = inputTextureCoordinate.xy + blurStep;
     }
 }
 );

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageBilateralFilterFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 const lowp int GAUSSIAN_SAMPLES = 9;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 uniform mediump float distanceNormalizationFactor;
 
 void main()
 {
     lowp vec4 centralColor;
     lowp float gaussianWeightTotal;
     lowp vec4 sum;
     lowp vec4 sampleColor;
     lowp float distanceFromCentralColor;
     lowp float gaussianWeight;
     
     
     
     centralColor = texture2D(inputImageTexture, blurCoordinates[4]);
     gaussianWeightTotal = 0.18;
     sum = centralColor * 0.18;
     lowp vec4 centralColor1;
     centralColor1 = texture2D(inputImageTexture, blurCoordinates[4]);
     
     
     lowp vec4 sumhpass;
     sumhpass = texture2D(inputImageTexture, blurCoordinates[4]);
     sumhpass = sumhpass*0.18;

     
     mediump float dis;
     dis = distance(textureCoordinate, vec2(0.5, 0.5));
     //dis = sqrt((blurCoordinates[4].x - 180)*(blurCoordinates[4].x - 180)+(blurCoordinates[4].y - 180)*(blurCoordinates[4].y - 180))/180;
     if((centralColor.r > 0.372549 && centralColor.g > 0.156863 && centralColor.b > 0.078431 && centralColor.r - centralColor.g > 0.058823 && centralColor.r - centralColor.b > 0.058823) ||
        (centralColor.r > 0.784314 && centralColor.g > 0.823530 && centralColor.b > 0.666667 && abs(centralColor.r - centralColor.b) <= 0.058823 && centralColor.r > centralColor.b && centralColor.g > centralColor.b)) {
         sampleColor = texture2D(inputImageTexture, blurCoordinates[0]);
         sumhpass += 0.05 * sampleColor;
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[1]);
         sumhpass += 0.09 * sampleColor;
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[2]);
         sumhpass += 0.12 * sampleColor;
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[3]);
         sumhpass += 0.15 * sampleColor;
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[5]);
         sumhpass += 0.15 * sampleColor;
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[6]);
         sumhpass += 0.12 * sampleColor;
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[7]);
         sumhpass += 0.09 * sampleColor;
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[8]);
         sumhpass += 0.05 * sampleColor;
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sumhpass = min(sumhpass, 1.0);
         mediump float rpass;
         mediump float gpass;
         mediump float bpass;
         rpass = min((centralColor.r - sumhpass.r)*(centralColor.r - sumhpass.r)*0.166667, 1.0);
         gpass = min((centralColor.g - sumhpass.g)*(centralColor.g - sumhpass.g)*0.166667, 1.0);
         bpass = min((centralColor.b - sumhpass.b)*(centralColor.b - sumhpass.b)*0.166667, 1.0);
         mediump float tp = 0.000243;
         //mediump float tp = 0.000143;
         if(rpass > tp || gpass > tp || bpass > tp) {
             gl_FragColor = vec4(centralColor.r, centralColor.g, centralColor.b, gl_FragColor.w);
             //gl_FragColor = vec4(1, 1, 1, gl_FragColor.w);
         } else {
             gl_FragColor = sum / gaussianWeightTotal;
                  mediump float r;
                  mediump float g;
                  mediump float b;
//                  r = min((0.6*gl_FragColor.r + 0.4*centralColor1.r), 1.0);
//                  g = min((0.6*gl_FragColor.g + 0.4*centralColor1.g), 1.0);
//                  b = min((0.6*gl_FragColor.b + 0.4*centralColor1.b), 1.0);
             
             r = min((0.6*gl_FragColor.r + 0.4*centralColor1.r), 1.0);
             g = min((0.6*gl_FragColor.g + 0.4*centralColor1.g), 1.0);
             b = min((0.6*gl_FragColor.b + 0.4*centralColor1.b), 1.0);
             
                  gl_FragColor = vec4(r, g, b, gl_FragColor.w);
         }
         
         
         
     } else {
         //gl_FragColor = vec4(0.0, 0.0, 0.0, gl_FragColor.w);
         gl_FragColor = vec4(centralColor.r, centralColor.g, centralColor.b, gl_FragColor.w);
     }

     if(dis <= 0.5) {
         mediump float r;
         mediump float g;
         mediump float b;
         r = min((gl_FragColor.r + gl_FragColor.r - gl_FragColor.r * gl_FragColor.r), 1.0);
         r = min(gl_FragColor.r + (0.5-dis)*r*(r - gl_FragColor.r), 1.0);
         g = min((gl_FragColor.g + gl_FragColor.g - gl_FragColor.g * gl_FragColor.g), 1.0);
         g = min(gl_FragColor.g + (0.5-dis)*g*(g-gl_FragColor.g), 1.0);
         b = min((gl_FragColor.b + gl_FragColor.b - gl_FragColor.b * gl_FragColor.b), 1.0);
         b = min(gl_FragColor.b + 1.4*(0.5-dis)*b*(b-gl_FragColor.b), 1.0);
         gl_FragColor = vec4(r, g, b, gl_FragColor.w);
     }

 }
 );
#else
NSString *const kGPUImageBilateralFilterFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 const int GAUSSIAN_SAMPLES = 9;
 
 varying vec2 textureCoordinate;
 varying vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 uniform float distanceNormalizationFactor;
 
 void main()
 {
     vec4 centralColor;
     float gaussianWeightTotal;
     vec4 sum;
     vec4 sampleColor;
     float distanceFromCentralColor;
     float gaussianWeight;
     centralColor = texture2D(inputImageTexture, blurCoordinates[4]);
     centralColor1 = texture2D(inputImageTexture, blurCoordinates[4]);
     float tmpr = centralColor.r;
     float tmpg = centralColor.g;
     float tmpb = centralColor.b;
     gaussianWeightTotal = 0.18;
     sum = centralColor * 0.18;
     
     mediump float dis;
     dis = distance(textureCoordinate, vec2(0.5, 0.3));
     //dis = sqrt((blurCoordinates[4].x - 180)*(blurCoordinates[4].x - 180)+(blurCoordinates[4].y - 180)*(blurCoordinates[4].y - 180))/180;
     if((centralColor.r > 0.372549 && centralColor.g > 0.156863 && centralColor.b > 0.078431 && centralColor.r - centralColor.g > 0.058823 && centralColor.r - centralColor.b > 0.058823) ||
        (centralColor.r > 0.784314 && centralColor.g > 0.823530 && centralColor.b > 0.666667 && abs(centralColor.r - centralColor.b) <= 0.058823 && centralColor.r > centralColor.b && centralColor.g > centralColor.b)) {
         sampleColor = texture2D(inputImageTexture, blurCoordinates[0]);
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[1]);
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[2]);
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[3]);
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[5]);
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[6]);
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[7]);
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         sampleColor = texture2D(inputImageTexture, blurCoordinates[8]);
         distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
         gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
         gaussianWeightTotal += gaussianWeight;
         sum += sampleColor * gaussianWeight;
         
         gl_FragColor = sum / gaussianWeightTotal;
     } else {
         gl_FragColor = vec4(centralColor.r, centralColor.g, centralColor.b, gl_FragColor.w);
     }
    if(dis <= 0.5) {
        mediump float r;
        mediump float g;
        mediump float b;
        r = min((gl_FragColor.r + gl_FragColor.r - gl_FragColor.r * gl_FragColor.r), 1.0);
        r = min((r + dis * (gl_FragColor.r - r)), 1.0);
        r = min((0.3*r + 0.7 * gl_FragColor.r), 1.0);
        r = min(0.85*r + 0.15 * centralColor1.r, 1.0);
        g = min((gl_FragColor.g + gl_FragColor.g - gl_FragColor.g * gl_FragColor.g), 1.0);
        g = min((g + dis * (gl_FragColor.g - g)), 1.0);
        g = min((0.3*g + 0.7 * gl_FragColor.g), 1.0);
        g = min(0.85*g + 0.15 * centralColor1.g, 1.0);
        b = min((gl_FragColor.b + gl_FragColor.b - gl_FragColor.b * gl_FragColor.b), 1.0);
        b = min((b + dis * (gl_FragColor.b - b)), 1.0);
        b = min((0.3*b + 0.7 * gl_FragColor.b), 1.0);
        b = min(0.85*b + 0.15 * centralColor1.b, 1.0);
        gl_FragColor = vec4(r, g, b, gl_FragColor.w);
     }
 }
 );
#endif

@implementation GPUImageBilateralFilter

@synthesize distanceNormalizationFactor = _distanceNormalizationFactor;

- (id)init;
{
    
    if (!(self = [super initWithFirstStageVertexShaderFromString:kGPUImageBilateralBlurVertexShaderString
                              firstStageFragmentShaderFromString:kGPUImageBilateralFilterFragmentShaderString
                               secondStageVertexShaderFromString:kGPUImageBilateralBlurVertexShaderString
                             secondStageFragmentShaderFromString:kGPUImageBilateralFilterFragmentShaderString])) {
        return nil;
    }
    
    firstDistanceNormalizationFactorUniform  = [filterProgram uniformIndex:@"distanceNormalizationFactor"];
    secondDistanceNormalizationFactorUniform = [filterProgram uniformIndex:@"distanceNormalizationFactor"];
    //360*640
//    self.texelSpacingMultiplier = 1.3;
//    self.distanceNormalizationFactor = 2.0;
    //720*1280
    self.texelSpacingMultiplier = 1.6;
    self.distanceNormalizationFactor = 2.0;
    
    
    return self;
}


#pragma mark -
#pragma mark Accessors

- (void)setDistanceNormalizationFactor:(CGFloat)newValue
{
    _distanceNormalizationFactor = newValue;
    
    [self setFloat:newValue
        forUniform:firstDistanceNormalizationFactorUniform
           program:filterProgram];
    
    [self setFloat:newValue
        forUniform:secondDistanceNormalizationFactorUniform
           program:secondFilterProgram];
}

@end
