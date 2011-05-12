//
//  main.m
//  HSCountingInputStream
//
//  Created by BJ Homer on 4/13/11.
//  Copyright 2011 BJ Homer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSCountingInputStream.h"
#import "HSRandomDataInputStream.h"

void downloadFile();
void produceRandomData();

int main (int argc, const char * argv[])
{

	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	downloadFile();
	produceRandomData();

	[pool drain];
    return 0;
}

void clientCallback(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo) {
	UInt8 buffer[32];
	CFReadStreamRead(stream, buffer, 32);
	
	NSData *data = [NSData dataWithBytes:buffer length:32];
	NSLog(@"Here are 32 random bytes: %@", data);
	
    CFReadStreamClose(stream);
}

void produceRandomData() {
	HSRandomDataInputStream *randomStream = [[HSRandomDataInputStream alloc] init];
	CFReadStreamRef cfRandomStream = (CFReadStreamRef)randomStream;
	
	CFReadStreamScheduleWithRunLoop(cfRandomStream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopCommonModes);
	
	CFStreamClientContext context = {0};
	CFReadStreamSetClient(cfRandomStream, kCFStreamEventHasBytesAvailable, &clientCallback, &context);
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	
	
	

	
	[randomStream release];
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

