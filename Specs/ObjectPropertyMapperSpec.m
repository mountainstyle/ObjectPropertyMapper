//  Copyright (c) 2013 Pivotal Labs. This software is licensed under the MIT License.

#define EXP_SHORTHAND
#import "Expecta.h"

#import "ObjectPropertyMapper.h"


@interface ObjectWithSimpleProperties : NSObject

@property (strong, nonatomic, readwrite) id idProperty;
@property (strong, nonatomic, readwrite) NSString *stringProperty;
@property (strong, nonatomic, readwrite) NSValue *valueProperty;
@property (strong, nonatomic, readwrite) NSDictionary *dictionaryProperty;
@property (strong, nonatomic, readwrite) NSArray *arrayProperty;
@property (assign, nonatomic, readwrite) BOOL boolProperty;
@property (assign, nonatomic, readwrite) NSInteger integerProperty;

@end


@implementation ObjectWithSimpleProperties

@end


@interface SubclassWithSimpleProperties : ObjectWithSimpleProperties

@end


@implementation SubclassWithSimpleProperties

@end


SPEC_BEGIN(ObjectPropertyMapperSpec)

describe(@"ObjectPropertyMapper", ^{
    __block ObjectPropertyMapper *mapper;

    id idObject = [NSObject new];
    NSString *stringObject = @"aString";
    NSValue *valueObject = [NSValue valueWithPointer:(const void *)[NSNull null]];
    NSDictionary *dictionaryObject = @{@"aKey": @"aValue"};
    NSArray *arrayObject = @[@1, @2, @3];
    NSDictionary *simpleObjectProperties = @{
        @"idProperty": idObject,
        @"stringProperty": stringObject,
        @"valueProperty": valueObject,
        @"dictionaryProperty": dictionaryObject,
        @"arrayProperty": arrayObject,
        @"boolProperty": @YES,
        @"integerProperty": @42,
    };

    beforeEach(^{
        mapper = [ObjectPropertyMapper new];
    });

    it(@"should map values to simple properties", ^{
        ObjectWithSimpleProperties *simpleObject = [ObjectWithSimpleProperties new];

        [mapper applyProperties:simpleObjectProperties toObject:simpleObject];

        expect(simpleObject.idProperty).to.beIdenticalTo(idObject);
        expect(simpleObject.stringProperty).to.beIdenticalTo(stringObject);
        expect(simpleObject.valueProperty).to.beIdenticalTo(valueObject);
        expect(simpleObject.dictionaryProperty).to.beIdenticalTo(dictionaryObject);
        expect(simpleObject.arrayProperty).to.beIdenticalTo(arrayObject);
        expect(simpleObject.boolProperty).to.equal(YES);
        expect(simpleObject.integerProperty).to.equal(42);
    });

    it(@"should map values to inherited properties", ^{
        SubclassWithSimpleProperties *simpleObject = [SubclassWithSimpleProperties new];

        [mapper applyProperties:simpleObjectProperties toObject:simpleObject];

        expect(simpleObject.idProperty).to.beIdenticalTo(idObject);
        expect(simpleObject.stringProperty).to.beIdenticalTo(stringObject);
        expect(simpleObject.valueProperty).to.beIdenticalTo(valueObject);
        expect(simpleObject.dictionaryProperty).to.beIdenticalTo(dictionaryObject);
        expect(simpleObject.arrayProperty).to.beIdenticalTo(arrayObject);
        expect(simpleObject.boolProperty).to.equal(YES);
        expect(simpleObject.integerProperty).to.equal(42);
    });

    it(@"should map null to properties", ^{
        ObjectWithSimpleProperties *simpleObject = [ObjectWithSimpleProperties new];
        simpleObject.idProperty = idObject;
        simpleObject.stringProperty = stringObject;
        simpleObject.valueProperty = valueObject;
        simpleObject.dictionaryProperty = dictionaryObject;
        simpleObject.arrayProperty = arrayObject;
        simpleObject.boolProperty = YES;
        simpleObject.integerProperty = 42;

        NSDictionary *nullProperties = @{
            @"idProperty": [NSNull null],
            @"stringProperty": [NSNull null],
            @"valueProperty": [NSNull null],
            @"dictionaryProperty": [NSNull null],
            @"arrayProperty": [NSNull null],
        };

        [mapper applyProperties:nullProperties toObject:simpleObject];

        expect(simpleObject.idProperty).to.beNil();
        expect(simpleObject.stringProperty).to.beNil();
        expect(simpleObject.valueProperty).to.beNil();
        expect(simpleObject.dictionaryProperty).to.beNil();
        expect(simpleObject.arrayProperty).to.beNil();
    });
});

SPEC_END
