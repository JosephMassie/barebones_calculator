//
//  calculatorApp.swift
//  calculator
//
//  Created by Joseph Massie on 2/11/25.
//

import SwiftUI
import VungleAdsSDK

@main
struct calculatorApp: App {
    init () {
        VungleAds.initWithAppId("5e13cc9d61880b27a65bf735") { error in
            if error != nil {
                print("Error initializing SDK")
            } else {
                print("Init is complete")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
