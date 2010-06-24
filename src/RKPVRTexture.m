/*

File: PVRTexture.m
Abstract: The PVRTexture class is responsible for loading .pvr files.

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import "RKPVRTexture.h"

#define PVR_TEXTURE_FLAG_TYPE_MASK	0xff

static char gPVRTexIdentifier[4] = "PVR!";

enum
{
	kPVRTextureFlagTypePVRTC_2 = 24,
	kPVRTextureFlagTypePVRTC_4
};

typedef struct _PVRTexHeader
{
	uint32_t headerLength;
	uint32_t height;
	uint32_t width;
	uint32_t numMipmaps;
	uint32_t flags;
	uint32_t dataLength;
	uint32_t bpp;
	uint32_t bitmaskRed;
	uint32_t bitmaskGreen;
	uint32_t bitmaskBlue;
	uint32_t bitmaskAlpha;
	uint32_t pvrTag;
	uint32_t numSurfs;
} PVRTexHeader;


@implementation RKPVRTexture

@synthesize name = _name;
@synthesize width = _width;
@synthesize height = _height;
@synthesize internalFormat = _internalFormat;
@synthesize hasAlpha = _hasAlpha;


- (BOOL)unpackPVRData {
	BOOL success = FALSE;
	PVRTexHeader *header = NULL;
	uint32_t flags, pvrTag;
	uint32_t formatFlags;
	
	bytes = NULL;
	dataLength = 0;
	
	header = (PVRTexHeader *)[data bytes];
	
	pvrTag = CFSwapInt32LittleToHost(header->pvrTag);

	if (gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
		gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
		gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
		gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff))
	{
		return FALSE;
	}
	
	flags = CFSwapInt32LittleToHost(header->flags);
	formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;
	
	if (formatFlags == kPVRTextureFlagTypePVRTC_4 || formatFlags == kPVRTextureFlagTypePVRTC_2)
	{

		if (formatFlags == kPVRTextureFlagTypePVRTC_4)
			_internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
		else if (formatFlags == kPVRTextureFlagTypePVRTC_2)
			_internalFormat = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
	
		_width  = CFSwapInt32LittleToHost(header->width);
		_height = CFSwapInt32LittleToHost(header->height);
		
		if (CFSwapInt32LittleToHost(header->bitmaskAlpha))
			_hasAlpha = TRUE;
		else
			_hasAlpha = FALSE;
		
		dataLength = CFSwapInt32LittleToHost(header->dataLength);
		
		bytes = ((uint8_t *)[data bytes]) + sizeof(PVRTexHeader);
		success = TRUE;
	}
	
	return success;
}


- (BOOL)createGLTexture
{
	
	GLenum err;
	
	
	if (_name != 0) {
		glDeleteTextures(1, &_name);
		NSLog(@"createGLTexture: Delete Texture in GPU: %d", _name);
	}
		
	glGenTextures(1, &_name);
	glBindTexture(GL_TEXTURE_2D, _name);
	
	
	
	NSLog(@"Create Texture in GPU: %d", _name);
		
	glCompressedTexImage2D(GL_TEXTURE_2D, 0, _internalFormat, _width, _height, 0, dataLength, bytes);
		
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		NSLog(@"Error uploading compressed texture. glError: 0x%04X", err);
		return FALSE;
	}
		
			
	
	
	
	return TRUE;
}

-(void) unload 
{
	if (_name != 0) {              //this is the only change - need to implement better wrapper however will do it in the wrapper
		glDeleteTextures(1, &_name);
		NSLog(@"unload: Delete Texture in GPU: %d", _name);
		_name = 0;
	}
}

- (id)initWithContentsOfFile:(NSString *)path
{
	if (self = [super init])
	{
		data = [[NSData dataWithContentsOfFile:path] retain];
		
		
		
		_name = 0;
		_width = _height = 0;
		_internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
		_hasAlpha = FALSE;
		
		if (!data || ![self unpackPVRData] )
		{
			NSLog(@"Failed loading texture %@",path);
			[self release];
			self = nil;
		}
	}
	
	return self;
}


- (id)initWithContentsOfURL:(NSURL *)url
{
	if (![url isFileURL])
	{
		[self release];
		return nil;
	}
	
	return [self initWithContentsOfFile:[url path]];
}


+ (id)pvrTextureWithContentsOfFile:(NSString *)path
{
	return [[[self alloc] initWithContentsOfFile:path] autorelease];
}


+ (id)pvrTextureWithContentsOfURL:(NSURL *)url
{
	if (![url isFileURL])
		return nil;
	
	return [RKPVRTexture pvrTextureWithContentsOfFile:[url path]];
}


- (void)dealloc
{
	[self unload];
	[data release];
	NSLog(@"RKPVRTexture dealloc");
	[super dealloc];
}

@end
