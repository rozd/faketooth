//
//  FakePeripheral.m
//  Faketooth
//
//  Created by Max Rozdobudko on 6/15/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import "FaketoothPeripheral.h"
#import "FaketoothService.h"

@implementation FaketoothPeripheral {
    NSUUID* _identifier;
    NSString* _name;
    NSArray<CBService*>* _services;
}

- (NSUUID*)identifier {
    return _identifier;
}

- (NSString*)name {
    return _name;
}

- (NSArray<CBService*>*)services {
    return _services;
}

- (instancetype)init {
    return self;
}

- (instancetype)initWithIdentifier:(NSUUID*)identifier name:(NSString*)name services:(NSArray<CBService*>*)services {
    _identifier = identifier;
    _name       = name;
    _services   = services;

    [_services enumerateObjectsUsingBlock:^(CBService * _Nonnull service, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([service isKindOfClass:FaketoothService.class]) {
            [((FaketoothService*)service) setPeripheral:self];
        }
    }];

    return self;
}

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic {
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)]) {
        [self.delegate peripheral:self didUpdateValueForCharacteristic:characteristic error:nil];
    }
}

@end
