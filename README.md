# LimitingMap
Show limiting on map area credits by Vladimir Kolbas[http://stackoverflow.com/users/1852805/vladimir-kolbas]


Hmm, my initial idea would be to use delegate method

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture;

to move the camera back when your scrolling limit is reached. Using this, your map view may overshoot your limit temporarily (depending on the frequency of delegate method call) when user scrolls to the end, but will animate back to your desired limit.

We can go into further details if you think this approach suits you.

UPDATE:

OK, actually I realised you should use another delegate method:

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
instead as it gives you constant position updates when moving. willMove is called only once before moving. Anyway, the idea is that you set up your map view and limits (bounding box), that would be e/g box of your overlay. I've just created an area around my location as an example and positioned initial camera position inside it. That's set up in viewDidLoad method.

Further, in didChangeCameraPosition method you

reposition the marker position so you can see where you're currently pointing
check if you've passed lat/long limits meaning you've passed bounds of your overlay and move/animate back
Mind that the code below doesn't check if you've passed through a corner (lat and long limit simultaneously), then you might end up off limits, but you can easily check for that condition with more if's.

Viewcontroller with mapview setup and delegate methods is below, and I've uploaded the complete project here: https://www.dropbox.com/s/1a599wowvkumaa8/LimitingMap.tar.gz . Please, don't forget to provide you API key in app delegate as I've removed mine from the code.

So, the view controller is as follows:

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController () <GMSMapViewDelegate> {
    CLLocationCoordinate2D center, topLeft, topRight, bottomLeft, bottomRight;
    double leftLong, rightLong, bottomLat, topLat;
    GMSMarker *currentPosition;
}

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // GMSMapview itself is wired in storyboard, just set delegate
    self.mapView.delegate = self;

    // Lat/long limits (bounding box)
    leftLong = 15.0;
    rightLong = 16.0;
    bottomLat  = 45.0;
    topLat  = 46.0;

    // center coordinate for map view and set it to mapview
    center = CLLocationCoordinate2DMake(45.895064, 15.858220);
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:center.latitude
                                                                    longitude:center.longitude
                                                                         zoom:10];
    self.mapView.camera = cameraPosition;

    // Current position, for displaying marker
    currentPosition = [GMSMarker markerWithPosition:center];
