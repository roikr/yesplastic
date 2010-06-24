//
//  ES1Renderer.m
//  YepPlastic
//
//  Created by Roee Kremer on 1/9/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ES1Renderer.h"
#import "glu.h"

@implementation ES1Renderer

// Create an ES 1.1 context
- (id) init
{
	if (self = [super init])
	{
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context])
		{
            [self release];
            return nil;
        }
		
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffersOES(1, &defaultFramebuffer);
		glGenRenderbuffersOES(1, &colorRenderbuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
	}
	
	return self;
}

- (void) render
{
}


- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{	
	// Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	NSLog(@"width: %i, height: %i",backingWidth,backingHeight);
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
	
	//[EAGLContext setCurrentContext:context];
	//glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
	
	float halfFov, theTan, screenFov, aspect;
	screenFov 		= 60.0f;
	
	eyeY 		= (float)backingHeight / 2.0;
	eyeX 		= (float)backingWidth / 2.0;
	halfFov 		= M_PI * screenFov / 360.0;
	theTan 			= tanf(halfFov);
	dist 		= eyeY / theTan;
	float nearDist 	= dist / 10.0;	// near / far clip plane
	float farDist 	= dist * 10.0;
	aspect 			= (float)backingWidth/(float)backingHeight;
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(screenFov, aspect, nearDist, farDist);
	
	glMatrixMode(GL_MODELVIEW);
	
    
    return YES;
}

- (void) dealloc
{
	// Tear down GL
	if (defaultFramebuffer)
	{
		glDeleteFramebuffersOES(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}

	if (colorRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
	// Tear down context
	if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
	
	[super dealloc];
}

- (void) setupView {
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
	
	glLoadIdentity();
	gluLookAt(eyeX, eyeY, dist, eyeX, eyeY, 0.0, 0.0, 1.0, 0.0);
	
	//glRotatef(90, 0.0, 0.0, 1.0	);
	glScalef(1.0, -1.0,1.0);
	glTranslatef(0, -backingHeight, 0);
	
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void) finishRendering {
	GLenum err;
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, defaultFramebuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	err = glGetError();
	if (err != GL_NO_ERROR)
		NSLog(@"Error in frame. glError: 0x%04X", err);
}

@end
