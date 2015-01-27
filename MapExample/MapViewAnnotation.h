//
//  MapViewAnnotation.h
//  MapExample
//
//  Created by Erick Bennett on 1/19/15.
//  Copyright (c) 2015 Erick Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapViewAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *googlePlacesID;

-(id) initWithTitle:(NSString *) annotationTitle andCoordinate:(CLLocationCoordinate2D) annotationCoordinate andGooglePlacesID:(NSString *) placesID;

@end
