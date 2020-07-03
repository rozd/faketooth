//
//  FakePeripheral.h
//  Faketooth
//
//  Created by Max Rozdobudko on 6/15/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface FaketoothPeripheral : CBPeripheral

- (void)setState:(CBPeripheralState)state;

- (instancetype)init;
- (instancetype)initWithIdentifier:(NSUUID*)identifier name:(NSString*)name services:(NSArray<CBService*>*)services;

- (void)notifyDidUpdateValueForCharacteristic:(CBCharacteristic*)characteristic;

@end

NS_ASSUME_NONNULL_END
