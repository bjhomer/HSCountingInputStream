//
//  HSCountingInputStream.m
//  HSCountingInputStream
//
//  Created by BJ Homer on 4/13/11.
//  Copyright 2011 BJ Homer. All rights reserved.
//

#import "HSCountingInputStream.h"


@implementation HSCountingInputStream 
{
	NSInputStream *parentStream;
	id <NSStreamDelegate> delegate;
	NSUInteger characterCounter;
	
	CFReadStreamClientCallBack copiedCallback;
	CFStreamClientContext copiedContext;
	CFOptionFlags requestedEvents;
}
@synthesize characterToCount;
@synthesize countedCharacters = characterCounter;


#pragma mark Object lifecycle

- (id)initWithInputStream:(NSInputStream *)stream
{
    self = [super init];
    if (self) {
        // Initialization code here.
		parentStream = [stream retain];
		[parentStream setDelegate:self];
    }
    
    return self;
}

- (void)dealloc
{
	[parentStream release];
    [super dealloc];
}

#pragma mark NSStream subclass methods

- (void)open {
	[parentStream open];
}

- (void)close {
	[parentStream close];
}

- (id <NSStreamDelegate> )delegate {
	return delegate;
}

- (void)setDelegate:(id<NSStreamDelegate>)aDelegate {
	delegate = aDelegate;
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
	[parentStream scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
	[parentStream removeFromRunLoop:aRunLoop forMode:mode];
}

- (id)propertyForKey:(NSString *)key {
	return [parentStream propertyForKey:key];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key {
	return [parentStream setProperty:property forKey:key];
}

- (NSStreamStatus)streamStatus {
	return [parentStream streamStatus];
}

- (NSError *)streamError {
	return [parentStream streamError];
}

#pragma mark NSInputStream subclass methods

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {
	NSInteger bytesRead = [parentStream read:buffer maxLength:len];
	
	for (int i=0; i<bytesRead; ++i) {
		if (buffer[i] == characterToCount) {
			++characterCounter;
		}
	}
	
	return bytesRead;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len {
	// We cannot implement our character-counting in O(1) time,
	// so we return NO as indicated in the NSInputStream
	// documentation.
	return NO;
}

- (BOOL)hasBytesAvailable {
	return [parentStream hasBytesAvailable];
}

#pragma mark Undocumented CFReadStream bridged methods

- (void)_scheduleInCFRunLoop:(CFRunLoopRef)aRunLoop forMode:(CFStringRef)aMode {

	CFReadStreamScheduleWithRunLoop((CFReadStreamRef)parentStream, aRunLoop, aMode);
}

- (BOOL)_setCFClientFlags:(CFOptionFlags)inFlags
                 callback:(CFReadStreamClientCallBack)inCallback
                  context:(CFStreamClientContext *)inContext {
	
	if (inCallback != NULL) {
		requestedEvents = inFlags;
		copiedCallback = inCallback;
		memcpy(&copiedContext, inContext, sizeof(CFStreamClientContext));
		
		if (copiedContext.info && copiedContext.retain) {
			copiedContext.retain(copiedContext.info);
		}
	}
	else {
		requestedEvents = kCFStreamEventNone;
		copiedCallback = NULL;
		if (copiedContext.info && copiedContext.release) {
			copiedContext.release(copiedContext.info);
		}
		
		memset(&copiedContext, 0, sizeof(CFStreamClientContext));
	}
	
	return YES;	
}

- (void)_unscheduleFromCFRunLoop:(CFRunLoopRef)aRunLoop forMode:(CFStringRef)aMode {

	CFReadStreamUnscheduleFromRunLoop((CFReadStreamRef)parentStream, aRunLoop, aMode);
}

#pragma mark NSStreamDelegate methods

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	
	assert(aStream == parentStream);
	
	switch (eventCode) {
		case NSStreamEventOpenCompleted:
			if (requestedEvents & kCFStreamEventOpenCompleted) {
				copiedCallback((CFReadStreamRef)self,
							   kCFStreamEventOpenCompleted,
							   copiedContext.info);
			}
			break;
			
		case NSStreamEventHasBytesAvailable:
			if (requestedEvents & kCFStreamEventHasBytesAvailable) {
				copiedCallback((CFReadStreamRef)self,
							   kCFStreamEventHasBytesAvailable,
							   copiedContext.info);
			}
			break;
			
		case NSStreamEventErrorOccurred:
			if (requestedEvents & kCFStreamEventErrorOccurred) {
				copiedCallback((CFReadStreamRef)self,
							   kCFStreamEventErrorOccurred,
							   copiedContext.info);
			}
			break;
			
		case NSStreamEventEndEncountered:
			if (requestedEvents & kCFStreamEventEndEncountered) {
				copiedCallback((CFReadStreamRef)self,
							   kCFStreamEventEndEncountered,
							   copiedContext.info);
			}
			break;
			
		case NSStreamEventHasSpaceAvailable:
			// This doesn't make sense for a read stream
			break;
			
		default:
			break;
	}
}


@end
