`HSCountingInputStream` is a simple example of an `NSInputStream` subclass
that works around the bugs you'll run into if you try to pass such a subclass
to NSURLRequest or CFHTTPMessageRef. See [my blog](http://bjhomer.blogspot.com/2011/04/subclassing-nsinputstream.html)
for more information on the gory details of how it works.

Note:

This sample uses a few language features only available if you're
using Xcode 4 and the LLVM Compiler 2.0, such as instance variables defined
in the @implementation block. It also relies on the modern runtime to
synthesize the instance variables.
I used these features because they're cool and I wanted people to be aware
of them.

So if it won't compile for you, that's probably why. It shouldn't
be hard to make the necessary changes to make it work for x86 or GCC 4.2,
if that's what you need to do.