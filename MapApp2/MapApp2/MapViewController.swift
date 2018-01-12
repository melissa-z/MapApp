import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    var homeLocation = CLLocation(latitude: 49.2398, longitude: -123.1338)
    
    @IBOutlet var menuButtons: [UIButton]!
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager =  CLLocationManager()
    let dataCollection = DataCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataCollection.restoreData()
        centerMapOnLocation(location: homeLocation)
        mapView.register(LocationMarkerView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        //gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.mapLongPress(_:)))
        longPress.minimumPressDuration = 1 //seconds
        mapView.addGestureRecognizer(longPress)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for location in dataCollection.locations {
            self.mapView.addAnnotation(location)
        }
    }
    
    //add location
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        let touchedAt = recognizer.location(in: self.mapView)
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)
        
        //alert
        let alertController = UIAlertController(title: "Location", message: "Please enter the name of this location:", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        
        self.present(alertController, animated: true, completion: nil)

        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            var newLocation: Location

            if let field = alertController.textFields![0] as? UITextField {
                if field.text != "" {
                    newLocation = Location(locationName: field.text!, coordinate: touchedAtCoordinate)
                } else {
                    newLocation = Location(locationName: "Unnamed", coordinate: touchedAtCoordinate)
                    UserDefaults.standard.set("Unnamed", forKey: "Name")
                }
                
                //filter
                DispatchQueue.main.async {
                    let filterAlertController = UIAlertController(title: "Filter", message: "Which list would you like to put this location into?", preferredStyle: .alert)
                    
                    let visitedOption = UIAlertAction(title: "Destination", style: .default) { (_) in
                        newLocation.category = "Destination"
                        self.dataCollection.destinations.append(newLocation)
                        self.dataCollection.locations.append(newLocation)
                        self.mapView.addAnnotation(newLocation)
                    }
                    let destinationsOption = UIAlertAction(title: "Visited", style: .default) { (_) in
                        newLocation.category = "Visited"
                        print(newLocation.category ?? "")
                        self.dataCollection.visited.append(newLocation)
                        self.dataCollection.locations.append(newLocation)
                        self.mapView.addAnnotation(newLocation)

                    }
                    let homeOption = UIAlertAction(title: "Set as Home", style: .default) { (_) in
                        newLocation.category = "Home"
                        self.dataCollection.home = newLocation
                        self.homeLocation = CLLocation(latitude: touchedAtCoordinate.latitude, longitude: touchedAtCoordinate.longitude)
                        self.dataCollection.locations.append(newLocation)
                        self.mapView.addAnnotation(newLocation)
                    }
                    
                    filterAlertController.addAction(destinationsOption)
                    filterAlertController.addAction(visitedOption)
                    filterAlertController.addAction(homeOption)
                    
                    self.present(filterAlertController, animated: true, completion: nil)
                }
            } else {
                //no valid location
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in print("cancelled") }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
    }
    
    let regionRadius: CLLocationDistance = 18000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    
    //buttons
    @IBAction func selectMenu(_ sender: UIButton) {
        menuButtons.forEach { (button) in
            if button.isHidden {
                button.isHidden = false
                button.alpha = 0
                UIView.animate(withDuration: 0.5, animations: {
                    button.alpha = 1
                })
            } else {
                button.alpha = 1
                UIView.animate(withDuration: 0.5, animations: {
                    button.alpha = 0
                }) { _ in
                    button.isHidden = true
                }
            }
        }
    }
    
    enum Options: String {
        case home = "Home"
        case visited = "Visited"
        case destinations = "Destinations"
        case showAll = "Show All"
    }
    
    @IBAction func optionTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let option = Options(rawValue: title) else {
            return
        }
        
        switch option {
        case .home:
            print("Home")
            if self.dataCollection.home != nil {mapView.addAnnotation(self.dataCollection.home!)}
            centerMapOnLocation(location: homeLocation)
            
        case .visited:
            print("Visited")
            mapView.removeAnnotations(mapView.annotations)
            
            for location in self.dataCollection.visited {
                mapView.addAnnotation(location)
            }
            
        case .destinations:
            print("Destinations")
            mapView.removeAnnotations(mapView.annotations)
            for location in self.dataCollection.destinations {
                mapView.addAnnotation(location)
            }
            
        case .showAll:
            print("Show ll")
            mapView.removeAnnotations(mapView.annotations)
            for location in self.dataCollection.locations {
                mapView.addAnnotation(location)
            }
        }
    }
}

