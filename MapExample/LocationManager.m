//
//  LocationManager.m
//  MapExample
//
//  Created by Erick Bennett on 1/19/15.
//  Copyright (c) 2015 Erick Bennett. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager
-(id) init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 10;
        [self.locationManager requestWhenInUseAuthorization];
    
    
    }
    return self;
    
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
    
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.currentLocation = [locations lastObject];
    
    if (self.startingLocation == nil) {
    
        self.startingLocation = self.currentLocation;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedLocation" object:self.currentLocation];
    }
    
}


@end
