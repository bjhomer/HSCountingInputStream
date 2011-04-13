//
//  HSCountingInputStream.h
//  HSCountingInputStream
//
//  Created by BJ Homer on 4/13/11.
//  Copyright 2011 BJ Homer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HSCountingInputStream : NSInputStream <NSStreamDelegate>

@property (assign) char characterToCount;
@property (readonly, assign) NSUInteger countedCharacters;

- (id)initWithInputStream:(NSInputStream *)stream;

@end
