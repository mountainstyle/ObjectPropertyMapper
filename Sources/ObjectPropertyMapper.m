//
//  ObjectPropertyMapper.m
//  ObjectPropertyMapper
//
//  Created by pivotal on 7/8/13.
//  Copyright (c) 2013-2014 Pivotal Labs.  This software is licensed under the MIT License.
//

#import "ObjectPropertyMapper.h"


@interface PropertyDetails : NSObject

@property (strong, nonatomic, readwrite) Class objectClass;
@property (strong, nonatomic, readwrite) NSString *propertyName;
@property (strong, nonatomic, readonly) Class propertyClass;

+ (id)newWithClass:(Class)objectClass name:(NSString *)propertyName;
- (id)initWithClass:(Class)objectClass name:(NSString *)propertyName;
- (BOOL)acceptsNull:(id)nullObject;
- (BOOL)acceptsMap:(NSDictionary *)propertyMap;
- (BOOL)acceptsObject:(id)propertyObject;
- (BOOL)acceptsValue:(id)propertyValue;

@end


@interface ObjectPropertyMapper ()

- (BOOL)property:(PropertyDetails *)property onObject:(id)object acceptsNull:(id)nullObject;
- (BOOL)property:(PropertyDetails *)property onObject:(id)object acceptsMap:(NSDictionary *)propertyMap;
- (BOOL)property:(PropertyDetails *)property onObject:(id)object acceptsObject:(id)propertyObject;
- (BOOL)property:(PropertyDetails *)property onObject:(id)object acceptsValue:(id)propertyValue;

@end


@implementation ObjectPropertyMapper

- (void)applyProperties:(NSDictionary *)properties toObject:(id)object {
    [properties enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, id propertyValue, BOOL *stop) {
        PropertyDetails *propertyDetails = [PropertyDetails newWithClass:[object class] name:propertyName];
        if ([self property:propertyDetails onObject:object acceptsNull:propertyValue]) {
            [object setValue:nil forKey:propertyName];
        }
        else if ([self property:propertyDetails onObject:object acceptsObject:propertyValue]) {
            [object setValue:propertyValue forKey:propertyName];
        }
        else if ([self property:propertyDetails onObject:object acceptsMap:propertyValue]) {
            id propertyInstance = [propertyDetails.propertyClass new];
            [object setValue:propertyInstance forKey:propertyName];
            [self applyProperties:(NSDictionary *)propertyValue toObject:propertyInstance];
        }
        else if ([self property:propertyDetails onObject:object acceptsValue:propertyValue]) {
            [object setValue:propertyValue forKey:propertyName];
        }
        else {
            NSLog(@"Could not map value for %@", propertyName);
        }
    }];
}

#pragma mark - Private methods

- (BOOL)property:(PropertyDetails *)property onObject:(id)object acceptsNull:(id)nullObject {
    return [property acceptsNull:nullObject];
}

- (BOOL)property:(PropertyDetails *)property onObject:(id)object acceptsMap:(NSDictionary *)propertyMap {
    return [property acceptsMap:propertyMap];
}

- (BOOL)property:(PropertyDetails *)property onObject:(id)object acceptsObject:(id)propertyObject {
    return [property acceptsObject:propertyObject];
}

- (BOOL)property:(PropertyDetails *)property onObject:(id)object acceptsValue:(NSValue *)propertyValue {
    return [property acceptsValue:propertyValue];
}

@end


#include "objc/runtime.h"


@interface PropertyDetails ()

@property (strong, nonatomic, readwrite) NSString *propertyType;
@property (strong, nonatomic, readwrite) Class propertyClass;

- (NSString *)typeOfProperty;

@end


@implementation PropertyDetails

+ (id)newWithClass:(Class)objectClass name:(NSString *)propertyName {
    return [[self alloc] initWithClass:objectClass name:propertyName];
}

- (id)initWithClass:(Class)objectClass name:(NSString *)propertyName {
    self = [super init];
    if (self) {
        self.objectClass = objectClass;
        self.propertyName = propertyName;
        self.propertyType = [self typeOfProperty];
        self.propertyClass = NSClassFromString(self.propertyType);
    }
    return self;
}

- (BOOL)acceptsNull:(id)nullObject {
    if (nullObject != [NSNull null]) return NO;

    return
        !!self.propertyClass
        || [self.propertyType isEqualToString:@"id"];
}

- (BOOL)acceptsMap:(NSDictionary *)propertyMap {
    if (![propertyMap isKindOfClass:[NSDictionary class]]) return NO;

    return !!self.propertyClass;
}

- (BOOL)acceptsObject:(id)propertyObject {
    if ([self.propertyType isEqualToString:@"id"]) return YES;

    return
        !!self.propertyClass
        && [[propertyObject class] isSubclassOfClass:self.propertyClass];
}

- (BOOL)acceptsValue:(id)propertyValue {
    return
        !self.propertyClass
        && [propertyValue isKindOfClass:[NSValue class]];
}

#pragma mark - Private methods

- (NSString *)typeOfProperty {
    // Mostly copied from: http://stackoverflow.com/a/13000074

    objc_property_t property = class_getProperty(self.objectClass, [self.propertyName UTF8String]);
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            return [[NSString alloc]
                    initWithBytes:attribute + 1
                    length:strlen(attribute) - 1
                    encoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return @"id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return [[NSString alloc]
                    initWithBytes:attribute + 3
                    length:strlen(attribute) - 4
                    encoding:NSASCIIStringEncoding];
        }
    }
    return @"";
}

@end
