//
//  FakeDescriptor.h
//  Faketooth
//
//  Created by Max Rozdobudko on 6/17/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

typedef id _Nullable(^FaketoothDescriptorValueProducer)(void);

@interface FaketoothDescriptor : CBDescriptor

- (void)setCharacteristic:(CBCharacteristic*)characteristic;
- (void)setValue:(NSData*)value;

- (instancetype)init;
- (instancetype)initWithUUID:(CBUUID*)uuid valueProducer:(nullable FaketoothDescriptorValueProducer)valueProducer;

@end

NS_ASSUME_NONNULL_END
