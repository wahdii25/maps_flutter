//
//  AppleMapView.swift
//  maps_flutter
//
//  Created by YUN WAH LEE on 16/1/24.
//

import Foundation
import MapKit
import Flutter

public class AppleMapView: NSObject, FlutterPlatformView {
    
    var channel: FlutterMethodChannel
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private var initialLocationSet = false
    private var pinAnnotation: MKPointAnnotation?
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var userCurrentCoordinate : CLLocationCoordinate2D?
    
    public init( withRegistrar registrar: FlutterPluginRegistrar) {
        self.channel = FlutterMethodChannel(name: "map_view_flutter", binaryMessenger: registrar.messenger())
        
        super.init()
        
        self.setMethodCallHandlers()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.userTrackingMode = .followWithHeading
        
        setupButton()

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleMapPan(_:)))
        mapView.addGestureRecognizer(panGestureRecognizer)
    }
    

    public func view() -> UIView {
        return mapView
    }
    
    private func setMethodCallHandlers() {
            channel.setMethodCallHandler({ [unowned self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                if let args: Dictionary<String, Any> = call.arguments as? Dictionary<String,Any> {
                    switch(call.method) {
                    case "getCurrentUserCoordinate":
                        let coordinateDictionary: [String: String] = [
                            "latitude": String(self.userCurrentCoordinate!.latitude),
                            "longitude": String(self.userCurrentCoordinate!.longitude)
                        ]
                        result(coordinateDictionary)
                        break
                    case "getAddress":
                        let geocoder = CLGeocoder()

                        geocoder.reverseGeocodeLocation(CLLocation(latitude: self.userCurrentCoordinate!.latitude, longitude: self.userCurrentCoordinate!.longitude)) { (placemarks, error) in
                            if let error = error {
                                print("Reverse geocoding failed with error: \(error.localizedDescription)")
                                return
                            }

                            if let placemark = placemarks?.first {
                                let address: [String: String] = [
                                    "address": placemark.name ?? "",
                                    "city": placemark.locality ?? "",
                                    "state": placemark.administrativeArea ?? "",
                                    "country": placemark.country ?? "",
                                    "postalCode": placemark.postalCode ?? ""
                                ]
                                
                                result(address)
                            } else {
                                result({})
                            }
                        }
                        break
                    default:
                        result(FlutterMethodNotImplemented)
                        break
                    }
                }
            })
        }
    
    func setupButton(){
        let buttonItem = MKUserTrackingButton(mapView: mapView)
        buttonItem.layer.backgroundColor = UIColor(white: 1, alpha: 1).cgColor
        buttonItem.layer.cornerRadius = 5
        
        buttonItem.frame = CGRect(origin: CGPoint(x:5, y: 25), size: CGSize(width: 45, height: 45))

        mapView.addSubview(buttonItem)
        
        buttonItem.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buttonItem.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -5),
            buttonItem.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 10),
            buttonItem.widthAnchor.constraint(equalToConstant: 45),
            buttonItem.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    @objc func handleMapPan(_ gestureRecognizer: UIPanGestureRecognizer) {
            // Update the pin's coordinate continuously during the pan gesture
            if gestureRecognizer.state == .changed {
                if let annotation = pinAnnotation {
                    let point = gestureRecognizer.location(in: mapView)
                    let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                    annotation.coordinate = coordinate
                }
            }
        }
    
    private func addPin(at coordinate: CLLocationCoordinate2D) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            pinAnnotation = annotation
        }
}

extension AppleMapView : CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userCurrentCoordinate = location.coordinate
        if !initialLocationSet {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
            initialLocationSet = true
            
            addPin(at: location.coordinate)
        }
    }
}

extension AppleMapView : MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if let annotation = pinAnnotation {
            annotation.coordinate = mapView.centerCoordinate
        }
   }
}
