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
import ObjectMapper
import UserNotifications
import Alamofire

fileprivate enum SessionCheckingStatus {
    
    case checking, checked, notChecked
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AKFViewControllerDelegate, UNUserNotificationCenterDelegate {

    fileprivate var coldStart = true

    fileprivate let manager = NetworkReachabilityManager(host: "www.apple.com")

    fileprivate var sessionStatus = SessionCheckingStatus.notChecked
    
    fileprivate var launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil
    
    fileprivate lazy var toast: UILabel = {
        
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.systemFont(ofSize: 12)
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        return toastLabel
    }()
    
    var window: UIWindow?
    
    static var appSettings: AppSettings = {
       
        let prod = "https://api.strizhapp.ru"
        let dev = "https://dev.api.strizhapp.ru"
        
        return AppSettings(dbConfig: STRealmConfiguration(),
                           serverApi: STServerApi(serverUrlString: prod))
    }()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.launchOptions = launchOptions
        
        // notifications
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            center.requestAuthorization(options: options, completionHandler: { (granted, error) in
                
                if !granted {
                    
                    return
                }
                
                application.registerForRemoteNotifications()
            })
            
        } else {
            
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil);
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        AppDelegate.appSettings.dbConfig.configure()
        
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey("AIzaSyB9Xe2_0osvR8RC8nBkRttpIEWOQuUbdI8")
        
        // Busy indicator setup
        NVActivityIndicatorView.DEFAULT_TYPE = .ballClipRotateMultiple
        
        self.reachabilitySetup()
        self.setupAnalytics()
        self.checkLaunchOptions()
        
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
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        guard self.coldStart == false else {
            
            return
        }
        
        if let payload = response.notification.request.content.userInfo as? [String : Any] {
            
            self.pushNotificationHandler(payload: payload)
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        let payload = userInfo as! [String : Any]
        
        if let type = payload["type"] as? String {
            
            switch type {
                
            case "message":
                
                if let newMessage = Mapper<STNewMessage>().map(JSON: payload) {
                    
                    // TODO checking for current dialog in chat
                    if let tabController = self.window?.rootViewController! as? STTabBarViewController {
                        
                        if let count = tabController.viewControllers?.count {
                            
                            for index in 0...count - 1 {
                                
                                let navi = tabController.viewControllers![index] as! UINavigationController
                                
                                if let chatController = navi.topViewController as? STChatViewController {
                                    
                                    if let dialog = chatController.dialog {
                                        
                                        if dialog.id == newMessage.dialogId {
                                            
                                            return
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            default:
                break
            }
        }
            
        completionHandler([.alert, .badge, .sound])
    }
 
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard
            userInfo is [String : Any] &&
            self.coldStart == false &&
            application.applicationState != .active
            
            else { return }
        
        if application.applicationState == .active {
            
            if #available(iOS 10.0, *) {
                
                let payload = userInfo as! [String : Any]
                
                if let type = payload["type"] as? String {
                    
                    switch type {
                        
                    case "message":
                        
                        if let newMessage = Mapper<STNewMessage>().map(JSON: payload) {
                            
                            // TODO checking for current dialog in chat
                            if let tabController = self.window?.rootViewController! as? STTabBarViewController {
                                
                                if let count = tabController.viewControllers?.count {
                                    
                                    for index in 0...count {
                                        
                                        let navi = tabController.viewControllers![index] as! UINavigationController
                                        
                                        if let chatController = navi.topViewController as? STChatViewController {
                                            
                                            if let dialog = chatController.dialog {
                                                
                                                if dialog.id == newMessage.dialogId {
                                                    
                                                    return
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            self.makeLocalNotification(title: newMessage.title, body: newMessage.message, payload: payload)
                        }
                        
                    case "post":
                        
                        if let newPost = Mapper<STNewPost>().map(JSON: payload) {
                            
                            self.makeLocalNotification(title: newPost.title, body: newPost.body, payload: payload)
                        }
                        
                    default:
                        break
                    }
                }
                
                return
            }
        }
        
        self.pushNotificationHandler(payload: userInfo as! [String : Any])
    }
    
    // MARK: AKFViewControllerDelegate implementation
    func viewController(_ viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
        
        let deviceToken = AppDelegate.appSettings.deviceToken
        let deviceUUID = UIDevice.current.identifierForVendor!.uuidString
        
        AppDelegate.appSettings.api.fbAuthorization(deviceToken: deviceToken, deviceUUID: deviceUUID, code: code)
            
            .onSuccess(callback: { [unowned self] session in
                
                session.writeToDB()
                self.onAuthorized()
                
                // check user
                AppDelegate.appSettings.api.loadUser(transport: .http, userId: session.userId)
                    
                    .onSuccess(callback: { [unowned self] user in
                        
                        if user.firstName.isEmpty {
                            
                            let controller = STSingUpTableViewController(signupStep: .signupThirdStep)
                            let navi = STSignUpNavigationController(rootViewController: controller)
                            
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
    
    func openMainController(completion: ((Bool) -> Void)? = nil) {
        
        let controller = AppDelegate.appSettings.storyBoard.instantiateViewController(withIdentifier: "TabBar")
        self.changeRootViewController(controller, completion: completion)
    }
    
    func onAuthorized() {
        
        AppDelegate.appSettings.api.onValidSession()
    }
    
    func onLogout() {
        
        AppDelegate.appSettings.dbConfig.onLogout()
        AppDelegate.appSettings.api.logout()
            .onSuccess { session in
                
                // delete all contacts
                STContactsProvider.sharedInstance.reset()
                AppDelegate.appSettings.fbAccountKit.logOut()
                STContactsProvider.sharedInstance.reset()
                
                self.checkSession(onComplete: { complete in
                    
                    self.coldStart = false
                })
            }
    }
    
    func introEnded() {
        
        let dip = AppDelegate.appSettings.dependencyContainer
        let analytics: STAnalytics = try! dip.resolve()
        analytics.endTimeEvent(eventName: st_eIntro)
        
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: kNeedIntro)
        defaults.synchronize()
        
        self.checkSession(animation: true, onComplete: { complete in
            
            self.coldStart = false
        })
    }
    
    // MARK: Internal methods
    
    func changeRootViewController(_ viewController: UIViewController, completion: ((Bool) -> Void)? = nil) {
        
        UIView.transition(with: self.window!,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            
                            UIView.performWithoutAnimation {
                                
                                self.window!.rootViewController = viewController
                            }
                            
//                            let oldState = UIView.areAnimationsEnabled
//                            UIView.setAnimationsEnabled(false)
//                            self.window!.rootViewController = viewController
//                            UIView.setAnimationsEnabled(oldState)
                            
        }, completion: completion)
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
        
        let dip = AppDelegate.appSettings.dependencyContainer
        dip.register(.singleton) { STAnalytics(analytics: [STFlurryAnalytics()]) as STAnalytics }
        
        let analytics: STAnalytics = try! dip.resolve()
        analytics.logEvent(eventName: "start")
    }
    
    fileprivate func makeLocalNotification(title: String, body: String, payload: [String : Any]) {
        
        if #available(iOS 10.0, *) {

            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings(completionHandler: { settings in
                
                if settings.authorizationStatus == .authorized {
                    
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = body
                    content.sound = UNNotificationSound.default()
                    content.userInfo = payload
                    
                    let identifier = "STLocalNotification"
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
                    
                    center.add(request, withCompletionHandler: { error in
                        
                        if let error = error {
                            
                            print(error)
                        }
                    })
                }
            })
        }
    }
    
    fileprivate func pushNotificationHandler(payload: [String : Any]) {
        
        if let type = payload["type"] as? String {
            
            switch type {
                
            case "message":
                
                if let newMessage = Mapper<STNewMessage>().map(JSON: payload) {
                    
                    if let tabController = self.window?.rootViewController! as? STTabBarViewController {
                        
                        if let count = tabController.viewControllers?.count {
                            
                            for index in 0...count {
                                
                                let navi = tabController.viewControllers![index] as! UINavigationController
                                
                                if let controller = navi.viewControllers.first(where: { $0 is STDialogsController }) {
                                    
                                    tabController.selectedIndex = index
                                    navi.popToViewController(controller, animated: false)
                                    
                                    let dialogsController = controller as! STDialogsController
                                    dialogsController.reason = .openFromPush
                                    dialogsController.openDialog(by: newMessage.dialogId)
                                    
                                    break
                                }
                            }
                        }
                    }
                }
                
                break
                
            case "post":
                
                if let newPost = Mapper<STNewPost>().map(JSON: payload) {
                    
                    if let tabController = self.window?.rootViewController! as? STTabBarViewController {
                        
                        if let count = tabController.viewControllers?.count {
                            
                            for index in 0...count {
                                
                                let navi = tabController.viewControllers![index] as! UINavigationController
                                
                                if let controller = navi.viewControllers.first(where: { $0 is STFeedTableViewController }) {
                                    
                                    tabController.selectedIndex = index
                                    navi.popToViewController(controller, animated: false)
                                    
                                    let postsController = controller as! STFeedTableViewController
                                    postsController.reason = .openFromPush
                                    postsController.openPostDetails(by: newPost.postId)
                                    
                                    break
                                }
                            }
                        }
                    }
                }
                
                break
                
            default:
                break
            }
        }
    }
    
    fileprivate func checkSession(animation: Bool = false, onComplete: ((Bool) -> Void)? = nil) {
        
        self.sessionStatus = .checking
        
        AppDelegate.appSettings.api.checkSession()
            
            .onSuccess { [unowned self] session in
                
                self.sessionStatus = .checked
                self.coldStart = false
                
                if !session.isExpired {
                    
                    // write session to db
                    session.writeToDB()
                    
                    // This must to call first
                    self.onAuthorized()
                    
                    // load user
                    AppDelegate.appSettings.api.loadUser(transport: .websocket, userId: session.userId)
                        .onSuccess(callback: { [unowned self] user in
                            
                            if user.firstName.isEmpty || user.lastName.isEmpty {
                                
                                let controller = STSingUpTableViewController(signupStep: .signupThirdStep)
                                let navi = STSignUpNavigationController(rootViewController: controller)
                                
                                self.changeRootViewController(navi)
                            }
                            else {
                                
                                self.openMainController(completion: onComplete)
                            }
                            
                            user.writeToDB()
                            user.updateUserImage()
                        })
                }
                else {
                    
                    // clear db
                    AppDelegate.appSettings.dbConfig.onLogout()
                    
                    if let _ = UserDefaults.standard.object(forKey: kNeedIntro) as? Bool {

                        if session.isFacebook {

                            let controller = AppDelegate.appSettings.fbAccountKit
                                .viewControllerForPhoneLogin() as! AKFViewController
                            controller.enableSendToFacebook = true
                            controller.delegate = self
                            controller.uiManager = STFaceBookUIManager(controller: controller as! UIViewController)
                            
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
                                return
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
            .onFailure { [unowned self] error in
                
                self.sessionStatus = .notChecked
            }
    }
    
    fileprivate func reachabilitySetup() {
        
        manager?.listener = { status in
        
            switch status {
                
            case .reachable(NetworkReachabilityManager.ConnectionType.wwan),
                 .reachable(NetworkReachabilityManager.ConnectionType.ethernetOrWiFi):
                
                self.toast.removeFromSuperview()
                
                if self.sessionStatus == .checked || self.coldStart == true {
                    
                    return
                }
                
                self.checkLaunchOptions()
                
                break
                
            case .notReachable, .unknown:
                
                self.showToast(message: "reachability_unreachable_text".localized)
                
                break
            }
        }
        
        manager?.startListening()
    }
    
    fileprivate func showToast(message: String) {
        
        guard let window = self.window, self.toast.superview == nil else {
            
            return
        }
        
        self.toast.alpha = 0
        window.addSubview(toast)
        
        self.toast.text = message
        self.toast.sizeToFit()
        let size = toast.frame.size
        let frame = window.rootViewController!.view.frame
        self.toast.frame = CGRect(x: frame.size.width / 2 - size.width / 2 - 10, y: frame.size.height - 100, width: size.width + 20, height: 35)
        
        UIView.animate(withDuration: 1.0, delay: 0.1, options: .curveEaseOut, animations: {
            
            self.toast.alpha = 1
            
        }, completion: nil)
    }
    
    fileprivate func checkLaunchOptions() {
        
        if let options = self.launchOptions {
            
            let key = UIApplicationLaunchOptionsKey("UIApplicationLaunchOptionsRemoteNotificationKey")
            
            if let payload = options[key] as? [String : Any] {
                
                self.checkSession(onComplete: { complete in
                    
                    self.coldStart = false
                    self.pushNotificationHandler(payload: payload)
                })
            }
            else {
                
                self.checkSession(onComplete: { complete in
                    
                    self.coldStart = false
                })
            }
        }
        else {
            
            self.checkSession(onComplete: { complete in
                
                self.coldStart = false
            })
        }
    }
}

