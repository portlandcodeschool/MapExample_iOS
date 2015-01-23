//
//  ViewController.m
//  MapExample
//
//  Created by Erick Bennett on 1/19/15.
//  Copyright (c) 2015 Erick Bennett. All rights reserved.
//

#import "ViewController.h"
#import "MapViewAnnotation.h"

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
                
                NSDictionary *geometry = [places objectForKey:@"geometry"];
                
                NSDictionary *location = [geometry objectForKey:@"location"];
                
                NSNumber *lat = [location objectForKey:@"lat"];
                
                NSNumber *lng = [location objectForKey:@"lng"];
                
                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
                
                MapViewAnnotation *annotation = [[MapViewAnnotation alloc] initWithTitle:name andCoordinate:latlng];
                
                [placesFound addObject:annotation];
                
                
            }
            
            [self performSelectorOnMainThread:@selector(displayNewAnnotations:) withObject:placesFound waitUntilDone:NO];
        }


    }]  resume];
    
    
}

-(void) displayNewAnnotations:(NSMutableArray *)places {
    
    [self.map removeAnnotations:self.map.annotations];
    
    [self.map addAnnotations:places];

}

-(void) showExampleAddAnnotation {
    
    CLLocationCoordinate2D portland = CLLocationCoordinate2DMake(45.5241, -122.676201);
    
    MapViewAnnotation *annotation = [[MapViewAnnotation alloc] initWithTitle:@"Test" andCoordinate:portland];
    
    [self.map addAnnotation:annotation];
    
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
