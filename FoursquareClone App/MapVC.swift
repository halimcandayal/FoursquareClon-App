//
//  MapVC.swift
//  FoursquareClone App
//
//  Created by Halimcan Dayal on 10.03.2022.
//

import UIKit
import MapKit
import Parse

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    
    
    @IBOutlet weak var mapkitView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonCliked))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backButtonClicked))
        
        mapkitView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer: )))
        recognizer.minimumPressDuration = 3
        mapkitView.addGestureRecognizer(recognizer)
        
        
        
    }
    @objc func chooseLocation(gestureRecognizer: UIGestureRecognizer) {
        
        let touches = gestureRecognizer.location(in: self.mapkitView)
        let coordinates = self.mapkitView.convert(touches, toCoordinateFrom: self.mapkitView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = PlaceModel.sharedInstance.placeName
        annotation.subtitle = PlaceModel.sharedInstance.placeType
        
        self.mapkitView.addAnnotation(annotation)
        
        PlaceModel.sharedInstance.placeLatitude = String(coordinates.latitude)
        PlaceModel.sharedInstance.placeLongitude = String(coordinates.longitude)
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
        let region = MKCoordinateRegion(center: location, span: span)
        mapkitView.setRegion(region, animated: true)
    }
    
    @objc func saveButtonCliked() {
        
        let placeModel = PlaceModel.sharedInstance
        
        let object = PFObject(className: "Places")
        object["name"] = placeModel.placeName
        object["type"] = placeModel.placeType
        object["atmosphere"] = placeModel.placeAtmosphere
        object["latitude"] = placeModel.placeLatitude
        object["longitude"] = placeModel.placeLongitude
        
        if let imageData = placeModel.placeImage.jpegData(compressionQuality: 0.5) {
            object["image"] = PFFileObject(name: "image.jpg", data: imageData)
        }
        
        object.saveInBackground { (succes , error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }else {
                self.performSegue(withIdentifier: "MapVCtoPlacesVC", sender: nil)
            }
                
        }
        
        
        
        
    }
    
    @objc func backButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
   
}
