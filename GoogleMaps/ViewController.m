//
//  ViewController.m
//  GoogleMaps
//
//  Created by Jon Wong on 29/07/2015.
//  Copyright (c) 2015 Jon Wong. All rights reserved.
//

#import "ViewController.h"
@import GoogleMaps;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *listNearestPlaces;

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableArray *places;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[GFLocationManager sharedInstance] addLocationManagerDelegate:self];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[GFLocationManager sharedInstance] removeLocationManagerDelegate:self];
}

#pragma mark - CFLocationManagerDelegateMethod
- (void) locationManagerDidUpdateLocation:(CLLocation *)location {
    //NSLog(@"%@", location);
    
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
    
    // Prepare the link that is going to be used on the GET request
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&rankby=distance&name=kfc&key=AIzaSyDZ4lP0Z0tn--bdhe_zchuyhFShhAM85Rg", self.latitude, self.longitude]];
    
    //NSLog(@"url %@", url);
    
    // Prepare the request object
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            timeoutInterval:30];
    
    // Prepare the variables for the JSON response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    
    // Construct a Array around the Data from the response
    NSDictionary* responseArray = [NSJSONSerialization
                                   JSONObjectWithData:urlData
                                   options:0
                                   error:&error];
    
    
    
    NSArray *items = [responseArray objectForKey:@"results"];
    //NSLog(@"results: %@, count: %lu", items, (unsigned long)items.count);
    
    self.places = [[NSMutableArray alloc] init];
    
    // latitude for single place
    //NSLog(@"item: %@", [items objectAtIndex:1]);
    
    
    
    for (int i=0; i<items.count; i++) {
        NSMutableDictionary *currentPlace = [[NSMutableDictionary alloc] init];
        
        [currentPlace setObject:[[items objectAtIndex:i] objectForKey:@"name"] forKey:@"name"];
        [currentPlace setObject:[[items objectAtIndex:i] objectForKey:@"vicinity"] forKey:@"address"];
        [currentPlace setObject:[[[[items objectAtIndex:i] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] forKey:@"lat"];
        [currentPlace setObject:[[[[items objectAtIndex:i] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] forKey:@"long"];
        //NSLog(@"item: %@", [[[[items objectAtIndex:i] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"]);
        
        [self.places addObject:currentPlace];
    }
    
    //NSLog(@"All Places geolocations: %@", self.places);
    
    // Create a GMSCameraPosition that tells the map to display the
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.latitude
                                                            longitude:self.longitude
                                                                 zoom:13];
    //self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    
    self.mapView.delegate = self;
    
    
    // Creates a marker in the center of the map.
    /*GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(latitude, longitude);
    marker.title = @"Current Location";
    marker.snippet = @"Me";
    marker.map = self.mapView;*/
    
    // Place markers for locations in JSON response
    for (int i=0; i<self.places.count; i++) {
        
        float laty = [[[self.places objectAtIndex:i] objectForKey:@"lat"] floatValue];
        float longy = [[[self.places objectAtIndex:i] objectForKey:@"long"] floatValue];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(laty, longy);
        marker.title = @"🍗 KFC";
        marker.snippet = [[self.places objectAtIndex:i] objectForKey:@"address"];
        UIImage *bucketMarker = [UIImage imageNamed:@"marker_bucket"];
        marker.icon = bucketMarker;
        marker.appearAnimation = YES;
        marker.map = self.mapView;
    }
    
    /*GMSMutablePath *path = [GMSMutablePath path];
     [path addCoordinate:CLLocationCoordinate2DMake(@(51.499).doubleValue,@(-0.093).doubleValue)];
     // KFC Elephant and Castle 51.488614, -0.095715
     [path addCoordinate:CLLocationCoordinate2DMake(@(51.489).doubleValue,@(-0.096).doubleValue)];
     
     GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
     rectangle.strokeWidth = 2.f;
     rectangle.map = self.mapView;*/
    
    [self.view addSubview:self.mapView];

    // Iterate through the object and print desired results
    
    //self.items = [[NSMutableArray alloc] initWithObjects:@"One",@"Two",@"Three",@"Four",@"Five",@"Six",@"Seven",@"Eight",@"Nine", nil];
    
    [self.listNearestPlaces reloadData];
    
    /*[[responseArray objectForKey:@"results"] enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
     if (index < 1) {
     [self doSomethingWith:object];
     }
     
     }];*/
}

- (BOOL) didTapMyLocationButtonForMapView:(GMSMapView*)mapView {
    //NSLog(@"Location button pressed");
    GMSCameraPosition *currentPosition = [GMSCameraPosition cameraWithLatitude:self.latitude
                                                                   longitude:self.longitude
                                                                        zoom:13];
    [self.mapView animateToCameraPosition:currentPosition];
    
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Where we configure the cell in each row
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell... setting the text of our cell's label
    cell.textLabel.text = [[self.places objectAtIndex:indexPath.row] objectForKey:@"address"];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    // If you want to push another view upon tapping one of the cells on your table.
    
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    //NSLog(@"tapped: %ld", (long)indexPath.item);
    float latitude = [[[self.places objectAtIndex:indexPath.item] objectForKey:@"lat"] floatValue];
    float longitude = [[[self.places objectAtIndex:indexPath.item] objectForKey:@"long"] floatValue];
    
    
    [self.mapView animateToZoom:13];
    double delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //[self.mapView animateToLocation:CLLocationCoordinate2DMake(latitude, longitude)];
        GMSCameraPosition *selectedPlace = [GMSCameraPosition cameraWithLatitude:latitude
                                                                longitude:longitude
                                                                     zoom:15];
        [self.mapView animateToCameraPosition:selectedPlace];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
