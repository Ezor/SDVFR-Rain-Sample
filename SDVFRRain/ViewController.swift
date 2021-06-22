//
//  ViewController.swift
//  SDVFRRain
//
//  Created by Julien Roze on 22/06/2021.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    private var overlayRain: MKTileOverlay?
    private var rainviewerData: RainviewerData?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.23, green: 0.22, blue: 0.22, alpha: 1.0)
        mapView.delegate = self

        // SDOACI Tile Overlay
        let template = "https://sdoaci.skydreamsoft.fr/FRANCE/Z{z}/{y}/{x}.png"
        let overlay = MKTileOverlay(urlTemplate: template)
        overlay.tileSize = CGSize(width: 512, height: 512)
        overlay.canReplaceMapContent = true
        mapView.addOverlay(overlay, level: .aboveLabels)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Load ranviewer data
        loadRainviewerData()
    }

}

// MARK: Map View Delegate

extension ViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let tileOverlay = overlay as? MKTileOverlay else {
                return MKOverlayRenderer()
        }
        let renderer = MKTileOverlayRenderer(tileOverlay: tileOverlay)
        // Radar transparency
        renderer.alpha = 0.9
        return renderer
    }
}

// MARK : Rainviewer stuff

extension ViewController {

    private func loadRainviewerData() {

        let url = URL(string: "https://api.rainviewer.com/public/weather-maps.json")!
        let session = URLSession.shared
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                print("rainviewer error \(String(describing: error))")
                return
            }
            guard let data = data else {
                print("rainviewer no data")
                return
            }

            let decoder = JSONDecoder()
            self.rainviewerData = try! decoder.decode(RainviewerData.self, from: data)

            DispatchQueue.main.async {
                self.displayRainviewerOverlay(time: self.rainviewerData!.radar.past.last!)
            }
        })
        task.resume()
    }

    private func displayRainviewerOverlay(time: RainviewerTime) {
        // Rainviewer Tile Overlay
        guard let rainviewerData = self.rainviewerData else {
            return
        }

        // 512 = tile size : 256 or 512
        // 2 = color : https://www.rainviewer.com/api/color-schemes.html
        // 1_1 = smooth_snow : https://www.rainviewer.com/api/weather-maps-api.html
        let rainTemplate = rainviewerData.host+time.path+"/512/{z}/{x}/{y}/2/1_1.png"

        // Remove previous overlay
        if let overlayRain = self.overlayRain {
            mapView.removeOverlay(overlayRain)
        }

        // Display overlay
        self.overlayRain = MKTileOverlay(urlTemplate: rainTemplate)
        overlayRain!.tileSize = CGSize(width: 512, height: 512)
        mapView.addOverlay(overlayRain!, level: .aboveLabels)
    }
}
