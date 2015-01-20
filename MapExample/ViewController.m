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
    
    [self showExampleAddAnnotation];
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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
