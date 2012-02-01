//
//  UIDevice+machine.h
//  UMP
//
//  Created by Adam Bemowski on 6/17/10.
//  Copyright 2010 UC Berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@interface UIDevice(machine)
- (NSString *)machine;
@end
