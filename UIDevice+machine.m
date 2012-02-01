//
//  UIDevice+machine.m
//  UMP
//
//  Created by Adam Bemowski on 6/17/10.
//  Copyright 2010 UC Berkeley. All rights reserved.
//

#import "UIDevice+machine.h"

@implementation UIDevice(machine)

- (NSString *)machine
{
	size_t size;
	
	// Set 'oldp' parameter to NULL to get the size of the data
	// returned so we can allocate appropriate amount of space
	sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
	
	// Allocate the space to store name
	char *name = malloc(size);
	
	// Get the platform name
	sysctlbyname("hw.machine", name, &size, NULL, 0);
	
	// Place name into a string
	NSString *machine = [NSString stringWithFormat:@"%c", name];
	
	// Done with this
	free(name);
	
	return machine;
}

@end
