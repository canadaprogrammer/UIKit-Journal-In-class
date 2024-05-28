//
//  MapViewController.swift
//  JRNL
//
//  Created by Jungjin Park on 2024-05-14.
//

import UIKit
import CoreLocation
import MapKit
import SwiftData

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    let locationManager = CLLocationManager()
//    var sampleJournalEntryData = SampleJournalEntryData()
    var selectedJournalEntry: JournalEntry?
    
    var container: ModelContainer?
    var context: ModelContext?
    var annotations: [JournalMapAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.navigationItem.title = "Loading..."
//        locationManager.requestLocation()
        
        mapView.delegate = self
//        sampleJournalEntryData.createSampleJournalEntryData()
        guard let _container = try? ModelContainer(for: JournalEntry.self) else {
            fatalError("Could not initialize Container")
        }
        container = _container
        context = ModelContext(_container)
//        mapView.addAnnotations(sampleJournalEntryData.journalEntries)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        mapView.removeAnnotations(annotations)
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let myLocation = locations.first {
            let lat = myLocation.coordinate.latitude
            let long = myLocation.coordinate.longitude
            self.navigationItem.title = "Map"
            mapView.region = setInitialRegion(lat: lat, long: long)
//            mapView.addAnnotations(SharedData.shared.getAllJournalEntries())
            let descriptor = FetchDescriptor<JournalEntry>(predicate: #Predicate { $0.latitude != nil && $0.longitude != nil})
            guard let journalEntries = try? context?.fetch(descriptor) else {
                return
            }
            annotations = journalEntries.map { JournalMapAnnotation(journal: $0) }
            mapView.addAnnotations(annotations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        let identifier = "mapAnnotation"
        if annotation is JournalMapAnnotation {
            if let annotationview = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationview.annotation = annotation
                return annotationview
            } else {
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = true
                let callloutButton = UIButton(type: .detailDisclosure)
                annotationView.rightCalloutAccessoryView = callloutButton
                return annotationView
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = mapView.selectedAnnotations.first else {
            return
        }
        selectedJournalEntry = (annotation as? JournalMapAnnotation)?.journal
        self.performSegue(withIdentifier: "showMapDetail", sender: self)
    }
    
    // MARK: - navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "showMapDetail" else {
            fatalError("Unexpected segue identifier")
        }
        guard let entryDetailViewController = segue.destination as? JournalEntryDetailViewController else {
            fatalError("Unexpected view controller")
        }
        entryDetailViewController.selectedJournalEntry = selectedJournalEntry
    }
    
    // MARK: - Methods
    func setInitialRegion(lat: CLLocationDegrees, long: CLLocationDegrees) -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
}
