//
//  AppDelegate.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 19/04/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit
import Parse
import UserNotifications

//let appColor = UIColor(r: 255, g: 59, b: 48)
let navBarColor = UIColor(r: 0, g: 122, b: 255)
let sectionColor = UIColor(r: 142, g: 142, b: 147)

// Parse Server
fileprivate let appID = "Cf3dl00@18"
fileprivate let  appURL = "https://apps.vmn.cfe.mx/parse"
//fileprivate let  appURL = "http://10.59.20.30:1337/parse" //test ip from intranet
//fileprivate let  appURL = "http://10.59.20.37:1337/parse" //test ip from intranet IREFALLA NACIONAL

// global vars
var currentUser = PFUser.current()
var currentUserData: PFObject? {
    let userData = currentUser?.object(forKey: "userData") as? PFObject
    guard let usrFetch = try? userData?.fetch() else { return nil }
    return usrFetch
}
//var division: String? {
//    return currentUser?.value(forKey: "division") as? String
//}
//var zona: String? {
//    return currentUser?.value(forKey: "zona") as? String
//}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        self.window?.tintColor = appColor
        UINavigationBar.appearance().barTintColor = navBarColor
        UINavigationBar.appearance().backgroundColor = navBarColor
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UNUserNotificationCenter.current().delegate = self
        configureParse()
        registerForPushNotifications()
        
        return true
    }
    
    // LOAD PARSE AND REGISTER CLASES
    fileprivate func configureParse() {
        
//        Parse.enableLocalDatastore()
        Parse.initialize(with: ParseClientConfiguration {
            $0.isLocalDatastoreEnabled = true
            $0.applicationId = appID
            $0.server = appURL
            $0.clientKey = ""
        })

        UcmSOE.registerSubclass()
        UcmEvent.registerSubclass()
        RegistroCNN.registerSubclass()
        Mensaje.registerSubclass()
        Image.registerSubclass()
        Subestacion.registerSubclass()
        Causa.registerSubclass()
        Ubicacion.registerSubclass()
        EventoMayor.registerSubclass()
        LineaAT.registerSubclass()
        Division.registerSubclass()
    }
    
    
    fileprivate func registerForPushNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("notification in fore")
        NotificationCenter.default.post(name: NSNotification.Name("reloadCNN"), object: nil)
        completionHandler([.alert, .sound, .badge])
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("notification in action response")
        let content = response.notification.request.content
        notificationAction(content: content)
        completionHandler()
    }
    
    private func notificationAction(content: UNNotificationContent) {

        switch content.categoryIdentifier {
        case "RegistroCNN", "restablecimientos":
            NotificationCenter.default.post(name: NSNotification.Name("reloadCNN"), object: nil)
        case "evidencias", "informativo":
            guard let currentVC = UIApplication.shared.topMostViewController()else {break}
            AlertDialog.ShowAlert(viewController: currentVC, title: "Aviso!", message: content.body, actions: nil, fields: nil, completion: nil)
        default:
            break
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("back", userInfo)
        PFPush.handle(userInfo)
        completionHandler(.newData)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        if #available(iOS 10.0, *) {
            DBManager.saveContext()
        } else {
            // Fallback on earlier versions
        }
    }
}
