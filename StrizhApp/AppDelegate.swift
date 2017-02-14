//
//  AppDelegate.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var appSettings: AppSettings = {
       
        return AppSettings(dbConfig: STRealmConfiguration(),
                           serverApi: STServerApi(serverUrlString: "https://strizhapp.ru"))
    }()
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // register for notifications
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil);
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        AppDelegate.appSettings.dbConfig.configure()
        
        FIRApp.configure()
        
        GMSServices.provideAPIKey("AIzaSyB9Xe2_0osvR8RC8nBkRttpIEWOQuUbdI8")
        
        if let session = STSession.objects(by: STSession.self).first {
            
            AppDelegate.appSettings.api.onValidSession()
            
            // load user
            AppDelegate.appSettings.api.loadUser(transport: .webSocket, userId: session.userId)
                .onSuccess(callback: { user in
                  
                    if user.firstName.isEmpty || user.lastName.isEmpty {
                        
                        let controller = STSingUpTableViewController(signupStep: .signupThirdStep)
                        let navi = STSignUpNavigationController(rootViewController: controller)
                        
                        self.changeRootViewController(navi)
                    }
                    else {
                        
                        self.onLogin()
                    }
                    
                    user.writeToDB()
                    user.updateUserImage()
                })
        }
        else {
            
            let controller = STSingUpTableViewController(signupStep: .signupFirstStep)
            let navi = STSignUpNavigationController(rootViewController: controller)
            self.window?.rootViewController = navi
            self.window?.makeKeyAndVisible()
        }
        
        if self.window?.rootViewController == nil {
            
            let splash = AppDelegate.appSettings.storyBoard.instantiateViewController(withIdentifier: "Splash")
            self.window?.rootViewController = splash
            self.window?.makeKeyAndVisible()
        }
        
        return true
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
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token =  deviceToken.map { String(format: "%02.2hhx", arguments: [$0]) }.joined()
        AppDelegate.appSettings.deviceToken = token
    }
    
    func onLogin() {
        
        if let controller = AppDelegate.appSettings.storyBoard.instantiateInitialViewController() {
            
            self.changeRootViewController(controller)
        }
    }
    
    func onLogout() {
        
        AppDelegate.appSettings.dbConfig.onLogout()
        AppDelegate.appSettings.api.logout()
            .onSuccess { session in
                
                print("logout")
                print(session)
        }
        
        let controller = STSingUpTableViewController(signupStep: .signupFirstStep)
        self.changeRootViewController(controller)
    }
    
    // MARK: Internal methods
    
    func changeRootViewController(_ viewController: UIViewController) {
        
        UIView.transition(with: self.window!,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            
                            let oldState = UIView.areAnimationsEnabled
                            UIView.setAnimationsEnabled(false)
                            self.window!.rootViewController = viewController
                            UIView.setAnimationsEnabled(oldState)
                            
        }, completion: nil)
    }
    
    // MARK: Private methods
    
    
}

