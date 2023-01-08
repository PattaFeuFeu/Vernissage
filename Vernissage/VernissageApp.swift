//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

@main
struct VernissageApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let coreDataHandler = CoreDataHandler.shared
    let applicationState = ApplicationState.shared
    
    @State var applicationViewMode: ApplicationViewMode = .loading
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                switch applicationViewMode {
                case .loading:
                    LoadingView()
                case .signIn:
                    SignInView { viewMode in
                        applicationViewMode = viewMode
                    }
                    .environment(\.managedObjectContext, coreDataHandler.container.viewContext)
                    .environmentObject(applicationState)
                case .mainView:
                    MainView()
                        .environment(\.managedObjectContext, coreDataHandler.container.viewContext)
                        .environmentObject(applicationState)
                }
            }
            .task {
                await AuthorizationService.shared.verifyAccount({ accountData in
                    guard let accountData = accountData else {
                        self.applicationViewMode = .signIn
                        return
                    }
                    
                    self.applicationState.accountData = accountData
                    self.applicationViewMode = .mainView
                })
                
                URLCache.shared.memoryCapacity = 10_000_000 // ~10 MB memory space
                URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
            }
            .navigationViewStyle(.stack)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                try? HapticService.shared.start()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                HapticService.shared.stop()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
     }
}