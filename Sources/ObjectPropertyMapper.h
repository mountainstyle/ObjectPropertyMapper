//
//  ObjectPropertyMapper.h
//  ObjectPropertyMapper
//
//  Created by pivotal on 7/8/13.
//  Copyright (c) 2013 Pivotal Labs. This software is licensed under the MIT License.
//

#import <Foundation/Foundation.h>


@interface ObjectPropertyMapper : NSObject

- (void)applyProperties:(NSDictionary *)properties toObject:(id)object;

@end
