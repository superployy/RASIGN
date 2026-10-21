import SwiftUI

@main
struct RASIGNApp: App {
    @AppStorage("lang") private var lang = "km"
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.locale, Locale(identifier: lang))
                .tint(Color(red: 0.10, green: 0.35, blue: 0.85))
        }
    }
}
