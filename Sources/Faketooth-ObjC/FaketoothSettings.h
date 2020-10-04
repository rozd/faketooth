//
//  MyClass.h
//
//
//  Created by Max Rozdobudko on 10/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef struct {
    float scanForPeripheralDelayInSeconds;
    float connectPeripheralDelayInSeconds;
    float cancelPeripheralConnectionDelayInSeconds;
    float discoverServicesDelayInSeconds;
    float discoverCharacteristicsDelayInSeconds;
    float discoverIncludedServicesDelayInSeconds;
    float discoverDescriptorsForCharacteristicDelayInSeconds;
    float readValueForCharacteristicDelayInSeconds;
    float writeValueForCharacteristicDelayInSeconds;
    float readValueForDescriptorDelayInSeconds;
    float writeValueForDescriptorDelayInSeconds;
    float setNotifyValueForCharacteristicDelayInSeconds;
} FaketoothDelaySettings;

@interface FaketoothSettings : NSObject

@property (class, assign, nonatomic) FaketoothDelaySettings delay;

@end

NS_ASSUME_NONNULL_END
