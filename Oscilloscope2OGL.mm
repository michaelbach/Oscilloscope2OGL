#include <OpenGL/gl.h>
#import "Oscilloscope2OGL.h"

@implementation Oscilloscope2OGL


static BOOL _inited1, _notInited2;
static NSMutableArray *allTraces; // has maxChannels objects, each object is a mutable array of samples
static NSMutableArray *traceColors;
static CGLContextObj cglContext;


//#define max(x,y) ((x) > (y)) ? (x) : (y)
#define min(x,y) ((x) > (y)) ? (y) : (x)


- (NSColor*) ColWithHue: (CGFloat) h brightness: (CGFloat) b {
	return [[NSColor colorWithDeviceHue: h saturation: 1.0 brightness: b alpha: 1.0] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
}

- (void) initOnce {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSRect frameRect = [self bounds];
	width = frameRect.size.width;  height = frameRect.size.height;
	if (_inited1 && !_notInited2) return;
	_inited1 = YES;  _notInited2 = NO;
	//	NSLog(@"OscilloscopeNChannelOGL>initOnce>width %f", width);
	numberOfPoints = (NSUInteger) round(width);
	maxNumberOfTraces = kMaxNumberOfTraces;
	numberOfTraces = 1;
	[self setIsDrawYZeroLines: YES];
#if !__has_feature(objc_arc)
	allTraces = [[NSMutableArray arrayWithCapacity: maxNumberOfTraces] retain];
#else
	allTraces = [NSMutableArray arrayWithCapacity: maxNumberOfTraces];
#endif
	for (NSUInteger iTrace=0; iTrace<maxNumberOfTraces; ++iTrace)
		[allTraces addObject: [NSMutableArray arrayWithCapacity: numberOfPoints]];
	for (NSMutableArray *aTrace in allTraces)
		for (NSUInteger i=0; i<numberOfPoints; ++i) [aTrace addObject: [NSNumber numberWithFloat: NAN]];
#if !__has_feature(objc_arc)
	self.backgroundColor = [[NSColor colorWithDeviceWhite:0.9f alpha:1.0f]  colorUsingColorSpaceName: NSDeviceRGBColorSpace];
#else
	self.backgroundColor = [[NSColor colorWithDeviceWhite:0.9f alpha:1.0f]  colorUsingColorSpaceName: NSDeviceRGBColorSpace];
#endif
	[self setFullscale: 1.0f];
	[self setLineWidth: 1.0f];
	[self setTraceZeroTop: YES];
#if !__has_feature(objc_arc)
	traceColors = [[NSMutableArray arrayWithCapacity: 7] retain];
#else
	traceColors = [NSMutableArray arrayWithCapacity: 7];
#endif
	[traceColors addObject: [self ColWithHue: 0.667 brightness: 0.6]];	// dark blue
	[traceColors addObject: [self ColWithHue: 0.250 brightness: 0.5]];	// dark green
	[traceColors addObject: [self ColWithHue: 0.000 brightness: 0.7]];	// dark red
	[traceColors addObject: [self ColWithHue: 0.500 brightness: 0.6]];	// dark cyan
	[traceColors addObject: [self ColWithHue: 0.833 brightness: 0.6]];	// dark magenta
	[traceColors addObject: [self ColWithHue: 0.125 brightness: 0.6]];	// dark yellow

	cglContext = (CGLContextObj)[[self openGLContext] CGLContextObj];
}


- (void) awakeFromNib {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (void) prepareOpenGL{	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self initOnce ];
}

- (void)dealloc {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
#if !__has_feature(objc_arc)
//	for (NSMutableArray *aTrace in allTraces) [aTrace release]; <–– die sind nicht retained
	[allTraces release];
//	for (NSColor *col in traceColors) [col release];
	[traceColors release];
	[backgroundColor release];
	[super dealloc];
#endif
}


- (BOOL)isOpaque {return YES;}


- (void)drawRect:(NSRect)rect {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (!_inited1 || _notInited2) return;	// the first call is for the full window and must be suppressed (otherwise covers all other objects). Don't really understand this.
	[self initOnce];
	CGLLockContext(cglContext);// must lock GL context because display link is threaded
	CGLSetCurrentContext(cglContext);
	NSUInteger numPnts = [[allTraces objectAtIndex: 0] count];
	glViewport(0, 0, (GLsizei) rect.size.width, (GLsizei) rect.size.height);
//	glClearColor([backgroundColor redComponent], [backgroundColor greenComponent], [backgroundColor blueComponent], 0.0f);
	glClearColor(0.5f, 0.5f, 0.5f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	glLoadIdentity();  
	glOrtho(0.0, numPnts, 0, rect.size.height, -1.0, 1.0);
	
	GLfloat traceHeight = height / numberOfTraces;
	glColor3f(0.8f, 0.8f, 0.8f);  glLineWidth(1.0f);
	for (NSUInteger iTrace = 1; iTrace < numberOfTraces; ++iTrace) {	// let's draw the dividing lines
		CGFloat yTrace = (isTraceZeroTop ? (numberOfTraces-iTrace) : iTrace) * traceHeight;
		glBegin(GL_LINE_STRIP);  glVertex2f(0, yTrace);  glVertex2f(numPnts, yTrace);  glEnd();
	}
	for (NSUInteger iTrace = 0; iTrace < numberOfTraces; ++iTrace) {
		NSMutableArray *aTrace = [allTraces objectAtIndex: iTrace];
		NSColor * traceColor = [traceColors objectAtIndex: (iTrace % traceColors.count)];
		glColor3f((float)[traceColor redComponent], (float)[traceColor greenComponent], (float)[traceColor blueComponent]);
		glLineWidth(self.lineWidth);
		glBegin(GL_LINE_STRIP);
		for (NSUInteger iSmpl=0; iSmpl < numPnts; ++iSmpl) {
			glVertex2f(iSmpl, ((isTraceZeroTop ? (numberOfTraces-iTrace-0.5) : (iTrace+0.5)) + [[aTrace objectAtIndex: iSmpl] floatValue]/maxValue) * height / numberOfTraces);
		}
		glEnd();
		if ([self isDrawYZeroLines]) {		// draw y-zero lines in same colour (last so the pattern is lost)
			glLineWidth(1.0f);
			glEnable(GL_LINE_STIPPLE);  glLineStipple((GLint)1, 0xCCCC);
			GLfloat y = (isTraceZeroTop ? (numberOfTraces-iTrace) : iTrace) * traceHeight - 0.5*traceHeight;
			glBegin(GL_LINE_STRIP);  glVertex2f(0, y);  glVertex2f(numPnts, y);  glEnd();
			glDisable(GL_LINE_STIPPLE);
		}
	}
	glFlush();
	CGLUnlockContext(cglContext);
	//	NSLog(@"OscilloscopeNChannelOGL>drawRect Exit\n");
}


- (void) advanceWithSample: (CGFloat) sampleValue {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self initOnce];
	numberOfTraces = 1;
	[self advanceWithSamples: [NSArray arrayWithObject: [NSNumber numberWithFloat: (float)sampleValue]]];
}
- (void) advanceWithSamples: (NSArray *) sampleArray {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self initOnce];
	NSUInteger nTraces = min(maxNumberOfTraces, sampleArray.count);
	if (nTraces != numberOfTraces) self.numberOfTraces = nTraces;
	for (NSUInteger iTrace = 0; iTrace < nTraces; ++iTrace) {
		NSMutableArray *aTrace = [allTraces objectAtIndex: iTrace];
		[aTrace removeObjectAtIndex: 0];  [aTrace addObject: [sampleArray objectAtIndex: iTrace]];
	}
	[self setNeedsDisplay:YES];
}


- (void) setTrace: (NSUInteger) iTrace toSweep: (NSArray *) sweep {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self initOnce];
	if (iTrace >= maxNumberOfTraces) return;
	if (iTrace >= numberOfTraces) self.numberOfTraces = iTrace+1;
	NSUInteger n = min(sweep.count, numberOfPoints);
	NSMutableArray *aTrace = [allTraces objectAtIndex: iTrace];
	for (NSUInteger iSmpl=0; iSmpl<n; ++iSmpl) [aTrace replaceObjectAtIndex:iSmpl withObject:[sweep objectAtIndex:iSmpl]];		
	[self setNeedsDisplay:YES];
}
- (void) setTraceToSweep: (NSArray *) sweep {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self initOnce];
	numberOfTraces = 1;  [self setTrace: 0 toSweep: sweep];
}


- (void) setFullscale: (CGFloat) maxVal {
	maxValue = (maxVal > 0.0) ? maxVal : -maxVal;
}
- (CGFloat) fullscale {	return maxValue; }



- (NSUInteger) numberOfTraces {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self initOnce];
	return numberOfTraces;
}
- (void) setNumberOfTraces:(NSUInteger) n {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self initOnce];
	if (n > maxNumberOfTraces) n = maxNumberOfTraces;
	numberOfTraces = n;
}


- (void) setColor: (NSColor *) color {
	[self initOnce];
	numberOfTraces = 1;  [traceColors replaceObjectAtIndex: 0 withObject: color];
}
- (void) setColor: (NSColor *) color forTrace: (NSUInteger) iTrace {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self initOnce];
	if (iTrace > maxNumberOfTraces) return;
	[traceColors replaceObjectAtIndex: iTrace withObject: color];
}


@synthesize maxNumberOfTraces;
@synthesize	numberOfPoints;
@synthesize width;
@synthesize height;
@synthesize backgroundColor;
@synthesize lineWidth;
@synthesize isTraceZeroTop;
@synthesize isDrawYZeroLines;


@end
