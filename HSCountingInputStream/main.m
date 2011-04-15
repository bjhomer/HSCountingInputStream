//
//  main.m
//  HSCountingInputStream
//
//  Created by BJ Homer on 4/13/11.
//  Copyright 2011 BJ Homer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSCountingInputStream.h"

void downloadFile();

int main (int argc, const char * argv[])
{

	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	downloadFile();

	[pool drain];
    return 0;
}

void downloadFile() {
	
	// A note: I'm using CFReadStreamCreateForHTTPRequest() here because it's the simplest way I know of
	// to use an input stream without requiring a web service running. This works just as well with an input
	// stream used as the message of an HTTP request.
	
	CFURLRef url = CFURLCreateWithString(NULL, CFSTR("http://bjhomer.blogspot.com"), NULL);
	CFHTTPMessageRef message = CFHTTPMessageCreateRequest(NULL, CFSTR("GET"), url, kCFHTTPVersion1_1);
	
	CFReadStreamRef readStream = CFReadStreamCreateForHTTPRequest(NULL, message);
	
	HSCountingInputStream *countingStream = [[HSCountingInputStream alloc] initWithInputStream:(NSInputStream *)readStream];
	countingStream.characterToCount = 'n';
	
	CFReadStreamScheduleWithRunLoop((CFReadStreamRef)countingStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	
	CFReadStreamOpen(readStream);
	
	uint8_t buffer[1024];
	while (CFReadStreamGetStatus(readStream) != kCFStreamStatusAtEnd) {
		[countingStream read:buffer maxLength:1024];
	}
	
	CFReadStreamClose(readStream);
	
	CFReadStreamUnscheduleFromRunLoop((CFReadStreamRef)countingStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	
	NSLog(@"There were %u '%c's in bjhomer.blogspot.com's home page", (int)countingStream.countedCharacters, countingStream.characterToCount);
	
	CFRelease(url);
	CFRelease(message);
	CFRelease(readStream);
	[countingStream release];
	
}

