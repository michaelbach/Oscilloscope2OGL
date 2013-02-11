/* OsziView */

#import <Cocoa/Cocoa.h>

#define kMaxNumberOfTraces 8

/*
History
=======

2012-08-03	added zero lines
2012-07-25	dividing lines lighter grey
2012-02-16	added "CGLLockContext" & unlock, not sure if this is really necessary
2011-08-08	change setter "setTraceZeroTop", simplified the color initialising
2011-01-26	exposed "initOnce", but it's not really necessary. Call was missing in one function.
			added "lineWidth", some small changes
2010-03-05	added functions for parity with non-OGL version, and dividing lines
2009-12-30	added @property

*/


@interface Oscilloscope2OGL : NSOpenGLView {
	BOOL isTraceZeroTop, isDrawYZeroLines;
	NSUInteger numberOfPoints, numberOfTraces, maxNumberOfTraces;
	CGFloat width, height, maxValue, lineWidth;
	NSColor *backgroundColor;
}

- (void) initOnce;

- (void) advanceWithSample: (CGFloat) sampleValue;				// switches to single channel mode
- (void) advanceWithSamples: (NSArray *) sampleArrayOfNumbers;	// switches multichannel mode with the correct number of traces
- (void) setTraceToSweep: (NSArray *) sweep;					// switches to single channel mode
- (void) setTrace: (NSUInteger) iTrace toSweep: (NSArray *) sweep;// in multichannel mode. Adjusts numberOfTraces if necessary

- (void) setFullscale: (CGFloat) maxVal;						// will be symmetric bipolar
- (CGFloat) fullscale;
@property (readonly) NSUInteger numberOfPoints;					// width of the corresponding view in device points
- (NSUInteger) numberOfTraces;									// get number of traces (for multichannel mode)
- (void) setNumberOfTraces:(NSUInteger) n;						// set number of traces (for multichannel mode)
@property (readonly) NSUInteger maxNumberOfTraces;				// maximal possible number of traces (for multichannel mode)

@property (readonly) CGFloat width, height;						// view dimensions
- (void) setColor: (NSColor *) color;							// switches to single channel mode. Default: dark blue.
- (void) setColor: (NSColor *) color forTrace: (NSUInteger) iTrace;// multichannel. There are 7 predefined colors
#if !__has_feature(objc_arc)
@property (retain) NSColor *backgroundColor;					// default: very light grey
#else
@property (strong) NSColor *backgroundColor;					// default: very light grey
#endif
@property CGFloat lineWidth;
@property (setter=setTraceZeroTop:) BOOL isTraceZeroTop;											// trace ordering: trace zero is on top, or on bottom

@property	(readwrite)	BOOL isDrawYZeroLines;					// if YES: add y-zero lines (in the same colour as the trace, but dashed)

@end
