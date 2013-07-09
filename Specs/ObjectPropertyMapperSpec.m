//  Copyright (c) 2013 Pivotal Labs. This software is licensed under the MIT License.

#define EXP_SHORTHAND
#import "Expecta.h"

#import "ObjectPropertyMapper.h"


SPEC_BEGIN(ObjectPropertyMapperSpec)

describe(@"ObjectPropertyMapper", ^{
    __block ObjectPropertyMapper *mapper;

    beforeEach(^{
        mapper = [ObjectPropertyMapper new];
    });

    it(@"should exist", ^{
        expect(mapper).toNot.beNil();
    });
});

SPEC_END
