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
import NVActivityIndicatorView
import AccountKit
import Flurry_iOS_SDK
import Dip

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AKFViewControllerDelegate {

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
        
        self.setupAnalytics()
        self.checkSession()
        
        if self.window?.rootViewController == nil {
            
            let splash = AppDelegate.appSettings.storyBoard.instantiateViewController(withIdentifier: "Splash")
            self.window?.rootViewController = splash
            self.window?.makeKeyAndVisible()
        }
        
        // Busy indicator setup
        NVActivityIndicatorView.DEFAULT_TYPE = .ballClipRotateMultiple
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.introEnded), name: Notification.Name(rawValue: kIntroHasEndedNotification), object: nil)
        
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
    
    
    // MARK: AKFViewControllerDelegate implementation
    func viewController(_ viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
        
        let deviceToken = AppDelegate.appSettings.deviceToken ?? "xxxxxxxxxxxxxxxx"
        
        AppDelegate.appSettings.api.fbAuthorization(deviceToken: deviceToken, code: code)
            
            .onSuccess(callback: { [unowned self] session in
                
                // check user
                AppDelegate.appSettings.api.loadUser(transport: .http, userId: session.userId)
                    
                    .onSuccess(callback: { [unowned self] user in
                        
                        self.onAuthorized()
                        
                        if user.firstName.isEmpty {
                            
                            let controller = STSingUpTableViewController(signupStep: .signupThirdStep)
                            let navi = STNavigationController(rootViewController: controller)
                            
                            self.changeRootViewController(navi)
                            return
                        }
                        
                        user.writeToDB()
                        self.openMainController()
                    })
                    .onFailure(callback: { error in
                        
                        // TODO show error
                    })
            })
    }
    
    private func viewController(_ viewController: UIViewController!, didFailWithError error: NSError!) {
        
        print("We have an error \(error)")
    }
    
    func viewControllerDidCancel(_ viewController: UIViewController!) {
        
        print("The user cancel the login")
    }
    
    func openMainController() {
        
        if let controller = AppDelegate.appSettings.storyBoard.instantiateInitialViewController() {
            
            self.changeRootViewController(controller)
        }
    }
    
    func onAuthorized() {
        
        AppDelegate.appSettings.api.onValidSession()
    }
    
    func onLogout() {
        
        AppDelegate.appSettings.dbConfig.onLogout()
        AppDelegate.appSettings.api.logout()
            .onSuccess { session in
                
                print("logout")
                print(session)
        }
        
        // delete all contacts
        STContactsProvider.sharedInstance.reset()
        AppDelegate.appSettings.fbAccountKit.logOut()
        
        self.checkSession()
    }
    
    func introEnded() {
        
        let dip = AppDelegate.appSettings.dependencyContainer
        let analytics = try! dip.resolve(STFlurryAnalytics.self) as! STFlurryAnalytics
        analytics.endTimeEvent(eventName: st_eIntro)
        
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: kNeedIntro)
        defaults.synchronize()
        
        self.checkSession(animation: true)
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
    
    fileprivate func setupAnalytics() {
        
        let info = Bundle.main.infoDictionary
        let appVersion = info?["CFBundleShortVersionString"] as? String
        
        let builder = FlurrySessionBuilder.init()
            .withAppVersion(appVersion ?? "1.0")
            .withLogLevel(FlurryLogLevelAll)
            .withCrashReporting(true)
            .withSessionContinueSeconds(10)
        
        Flurry.startSession("B65KW7TXYQ8T4S7PPGZN", with: builder)
        
        let analytics = STAnalytics(analytics: [STFlurryAnalytics()])
        analytics.logEvent(eventName: "start")
        
        let dip = AppDelegate.appSettings.dependencyContainer
        dip.register(ComponentScope.singleton) { analytics }
    }
    
    fileprivate func checkSession(animation: Bool = false) {
        
        AppDelegate.appSettings.api.checkSession()
            
            .onSuccess { session in
                
                if !session.isExpired {
                    
                    // This must to call first
                    self.onAuthorized()
                    
                    // load user
                    AppDelegate.appSettings.api.loadUser(transport: .webSocket, userId: session.userId)
                        .onSuccess(callback: { user in
                            
                            if user.firstName.isEmpty || user.lastName.isEmpty {
                                
                                let controller = STSingUpTableViewController(signupStep: .signupThirdStep)
                                let navi = STSignUpNavigationController(rootViewController: controller)
                                
                                self.changeRootViewController(navi)
                            }
                            else {
                                
                                if let controller = AppDelegate.appSettings.storyBoard.instantiateInitialViewController() {
                                    
                                    self.changeRootViewController(controller)
                                }
                            }
                            
                            user.writeToDB()
                            user.updateUserImage()
                        })
                }
                else {
                    
                    if let _ = UserDefaults.standard.object(forKey: kNeedIntro) as? Bool {
                        
                        if session.isFacebook {
                            
                            let controller = AppDelegate.appSettings.fbAccountKit
                                .viewControllerForPhoneLogin() as! AKFViewController
                            controller.enableSendToFacebook = true
                            controller.delegate = self
                            
                            if animation {
                                
                                self.changeRootViewController(controller as! UIViewController)
                                return
                            }
                            
                            self.window?.rootViewController = controller as? UIViewController
                            self.window?.makeKeyAndVisible()
                        }
                        else {
                            
                            let controller = STSingUpTableViewController(signupStep: .signupFirstStep)
                            let navi = STSignUpNavigationController(rootViewController: controller)
                            
                            if animation {
                                
                                self.changeRootViewController(navi)
                            }
                            
                            self.window?.rootViewController = navi
                            self.window?.makeKeyAndVisible()
                        }
                    }
                    else {
                        
                        let controller = STIntroContainerViewController.controllerInstance()
                        self.changeRootViewController(controller)
                    }
                }
        }
    }
}

