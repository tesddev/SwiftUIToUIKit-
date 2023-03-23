/*
See LICENSE folder for this sample’s licensing information.

Abstract:
 The scene delegate.
*/

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let rootViewController = TripLogsController()
        window!.rootViewController = UINavigationController(rootViewController: rootViewController)
        window!.makeKeyAndVisible()

        SampleData.generateSampleDataIfNeeded(
            context: PersistenceController.shared.persistentContainer.newBackgroundContext()
        )
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        PersistenceController.shared.saveContext(context: PersistenceController.shared.persistentContainer.viewContext)
    }
}
