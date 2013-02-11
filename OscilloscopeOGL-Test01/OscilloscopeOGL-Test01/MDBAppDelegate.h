//
//  MDBAppDelegate.h
//  OscilloscopeOGL-Test01
//
//  Created by Bach on 11.02.13.
//  Copyright (c) 2013 Bach. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Oscilloscope2OGL.h"

@interface MDBAppDelegate : NSObject <NSApplicationDelegate> {
	IBOutlet Oscilloscope2OGL *osci;
}


@property (assign) IBOutlet NSWindow *window;


@end
