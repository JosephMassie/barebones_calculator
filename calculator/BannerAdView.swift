//
//  BannerAdView.swift
//  calculator
//
//  Created by Joseph Massie on 2/12/25.
//

import SwiftUI
import VungleAdsSDK

enum BannerState {
    case idle
    case loading
    case loaded
    case presented
    case failed
}

struct BannerAdView: UIViewRepresentable {
    let placementId: String
    let bannerAd: VungleBanner
    @State var state = BannerState.idle
    
    init(placementId: String) {
        self.placementId = placementId
        self.bannerAd = VungleBanner(placementId: placementId, size: BannerSize.regular)
    }
    
    func setupAd(view: UIView) {
        if state == .idle {
            bannerAd.load()
        } else if state == .loaded {
            bannerAd.present(on: view)
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        bannerAd.delegate = context.coordinator
        
        if VungleAds.isInitialized() {
            setupAd(view: view)
        } else {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if VungleAds.isInitialized() {
                    setupAd(view: view)
                    if state == .failed || state == .presented {
                        timer.invalidate()
                    }
                }
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VungleBannerDelegate {
        var parent: BannerAdView
        
        init(_ bannerAdView: BannerAdView) {
            self.parent = bannerAdView
        }
        
        func bannerAdDidLoad(_ banner: VungleBanner) {
            print("Banner ad loaded")
            self.parent.state = BannerState.loaded
        }
        
        func bannerAdDidFailToLoad(_ banner: VungleBanner, withError error: NSError) {
            print("Banner ad failed to load: \(error)")
            self.parent.state = BannerState.failed
        }
        
        func bannerAdWillPresent(_ banner: VungleBanner) {
            print("banner Ad will present")
        }
        
        func bannerAdDidPresent(_ banner: VungleBanner) {
            print("banner Ad presented successfully")
            self.parent.state = BannerState.presented
        }

        func bannerAdDidFailToPresent(_ banner: VungleBanner, withError error: NSError) {
            print("banner Ad failed to present \(error)")
            self.parent.state = BannerState.failed
        }
        
        func bannerAdDidTrackImpression(_ banner: VungleBanner) {
            print("banner Ad tracked impression")
        }
        
        func bannerAdDidClick(_ banner: VungleBanner) {
            print("banner Ad clicked")
        }
        
        func bannerAdWillLeaveApplication(_ banner: VungleBanner) {
            print("banner Ad will leave application")
        }
        
        func bannerAdWillClose(_ banner: VungleBanner) {
            print("banner Ad will close")
        }
        
        func bannerAdDidClose(_ banner: VungleBanner) {
            print("banner Ad closed")
        }
    }
}
