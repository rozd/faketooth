//
//  MyClass.m
//
//
//  Created by Max Rozdobudko on 10/4/20.
//

#import "FaketoothSettings.h"

@implementation FaketoothSettings

static FaketoothDelaySettings _delaySettings = {
    .scanForPeripheralDelayInSeconds                        = 1.0,
    .connectPeripheralDelayInSeconds                        = 1.0,
    .cancelPeripheralConnectionDelayInSeconds               = 0.5,
    .discoverServicesDelayInSeconds                         = 0.1,
    .discoverCharacteristicsDelayInSeconds                  = 0.1,
    .discoverIncludedServicesDelayInSeconds                 = 0.1,
    .discoverDescriptorsForCharacteristicDelayInSeconds     = 0.1,
    .readValueForCharacteristicDelayInSeconds               = 0.1,
    .writeValueForCharacteristicDelayInSeconds              = 0.1,
    .readValueForDescriptorDelayInSeconds                   = 0.1,
    .writeValueForDescriptorDelayInSeconds                  = 0.1,
    .setNotifyValueForCharacteristicDelayInSeconds          = 0.1,
};

+ (FaketoothDelaySettings)delay {
    return _delaySettings;
}
+ (void)setDelay:(FaketoothDelaySettings)delaySettings {
    _delaySettings = delaySettings;
}

@end
