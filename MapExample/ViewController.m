//
//  ViewController.m
//  MapExample
//
//  Created by Erick Bennett on 1/19/15.
//  Copyright (c) 2015 Erick Bennett. All rights reserved.
//

#import "ViewController.h"
#import "MapViewAnnotation.h"
#import "PlaceDetailViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocationRange:) name:@"updatedLocation" object:nil];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnScreen)];
    
    tap.numberOfTapsRequired = 1;
    
    
    [self.view addGestureRecognizer:tap];
    
}

-(void) getPlacesFromGoogle {
    NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=300&sensor=false&keyword=%@&key=AIzaSyDfFhd0Uh5fvOw1daGh9zbVPbAVirn2qDU",self.map.userLocation.coordinate.latitude, self.map.userLocation.coordinate.longitude, self.searchBar.text];
    
    NSLog(@"urlstr = %@", urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        NSMutableDictionary *allData = [NSJSONSerialization
                                        JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                        error:&jsonError];
        
        
        NSArray *results = [allData objectForKey:@"results"];
        
        if (results.count > 0) {
            
            //since we dont care about the order of the places, we can use fast enumeration on the array to iterate thru it.
            //This will do the same as
            // for (int x = 0; x < results.count; x++) {
               // parse thru data
             //}
            NSMutableArray *placesFound = [NSMutableArray array];

            for (id object in results) {
                
                NSDictionary *places = object;
                
                NSString *name = [places objectForKey:@"name"];
                
                NSString *googlePlacesID = [places objectForKey:@"place_id"];
                
                NSDictionary *geometry = [places objectForKey:@"geometry"];
                
                NSDictionary *location = [geometry objectForKey:@"location"];
                
                NSNumber *lat = [location objectForKey:@"lat"];
                
                NSNumber *lng = [location objectForKey:@"lng"];
                
                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
                
                MapViewAnnotation *annotation = [[MapViewAnnotation alloc] initWithTitle:name andCoordinate:latlng andGooglePlacesID:googlePlacesID];
                
                [placesFound addObject:annotation];
                
                
            }
            
            [self performSelectorOnMainThread:@selector(displayNewAnnotations:) withObject:placesFound waitUntilDone:NO];
        }


    }]  resume];
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
    
    if ([annotation isKindOfClass:[MapViewAnnotation class]]) {
        
        MKAnnotationView *aView = (MKAnnotationView *) [self.map dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (aView == nil) {
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
            aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            aView.canShowCallout = YES;
            aView.annotation = annotation;
        } else {
            aView.annotation = annotation;
        }
        
        return aView;
        
    } else {
        return nil;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    MapViewAnnotation *annotation = view.annotation;
    
    [self getPlaceDetailWithID:annotation.googlePlacesID];
}

-(void) getPlaceDetailWithID:(NSString *)placeID {
    
    NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyDfFhd0Uh5fvOw1daGh9zbVPbAVirn2qDU", placeID];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        NSMutableDictionary *allData = [NSJSONSerialization
                                        JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                        error:&jsonError];
        
        NSDictionary *result = [allData objectForKey:@"result"];
        
        [self performSelectorOnMainThread:@selector(showPlaceDetail:) withObject:result waitUntilDone:NO];
        
    }]  resume];
    
}

-(void)showPlaceDetail:(NSDictionary *)result {
    
    [self performSegueWithIdentifier:@"showPlaceDetail" sender:result];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"showPlaceDetail"]) {
        
        NSDictionary *result = (NSDictionary *)sender;
        
        NSString *websiteLink = [result objectForKey:@"website"];
        
        NSString *name = [result objectForKey:@"name"];
    
        PlaceDetailViewController *pdc = segue.destinationViewController;
        pdc.urlString = websiteLink;
        pdc.title = name;
     
        
    }
}

-(void) displayNewAnnotations:(NSMutableArray *)places {
    
    [self.map removeAnnotations:self.map.annotations];
    
    [self.map addAnnotations:places];

}

-(void) updateLocationRange:(NSNotification *)notif {
    
    CLLocation *newLocation = notif.object;
    
    [self updateRegion:newLocation.coordinate];
}

-(void) updateRegion:(CLLocationCoordinate2D)location {
    
    self.map.showsUserLocation = YES;
    
    //Set the center coordinate to the values passed in.
    CLLocationCoordinate2D initialLocationFocus = location;
    
    //Set the span (how many degrees to show from the initial point)
    MKCoordinateSpan span = MKCoordinateSpanMake(.01, .01);
    
    //Create the region from above information
    MKCoordinateRegion region = MKCoordinateRegionMake(initialLocationFocus, span);
    
    //set the maps region.
    [self.map setRegion:region animated:YES];
    
}

-(void) didTapOnScreen {
    
    [self.searchBar resignFirstResponder];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    [self getPlacesFromGoogle];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
