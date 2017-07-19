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
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AKFViewControllerDelegate, UNUserNotificationCenterDelegate {

    fileprivate var coldStart = true
    
    fileprivate let reachability = Reachability()
    
    fileprivate var sessionChecked = false
    
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
       
        return AppSettings(dbConfig: STRealmConfiguration(),
                           serverApi: STServerApi(serverUrlString: "https://dev.api.strizhapp.ru"))
    }()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // notifications
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            center.requestAuthorization(options: options, completionHandler: { (granted, error) in
                
                if !granted {
                    
                    print(error!)
                }
                
                application.registerForRemoteNotifications()
            })
            
        } else {
            
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil);
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        AppDelegate.appSettings.dbConfig.configure()
        
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey("AIzaSyB9Xe2_0osvR8RC8nBkRttpIEWOQuUbdI8")
        
        self.reachabilitySetup()
        self.setupAnalytics()
        self.checkSession(launchOptions: launchOptions)
        
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
        
        let deviceToken = AppDelegate.appSettings.deviceToken ?? "xxxxxxxxxxxxxxxx"
        let deviceUUID = UIDevice.current.identifierForVendor!.uuidString
        
        AppDelegate.appSettings.api.fbAuthorization(deviceToken: deviceToken, deviceUUID: deviceUUID, code: code)
            
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
    
    func openMainController(completion: ((Bool) -> Swift.Void)? = nil) {
        
        if let controller = AppDelegate.appSettings.storyBoard.instantiateInitialViewController() {
            
            self.changeRootViewController(controller, completion: completion)
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
                
                // delete all contacts
                STContactsProvider.sharedInstance.reset()
                AppDelegate.appSettings.fbAccountKit.logOut()
                STContactsProvider.sharedInstance.reset()
                
                self.checkSession()
            }
    }
    
    func introEnded() {
        
        let dip = AppDelegate.appSettings.dependencyContainer
        let analytics: STAnalytics = try! dip.resolve()
        analytics.endTimeEvent(eventName: st_eIntro)
        
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: kNeedIntro)
        defaults.synchronize()
        
        self.checkSession(animation: true)
    }
    
    // MARK: Internal methods
    
    func changeRootViewController(_ viewController: UIViewController, completion: ((Bool) -> Swift.Void)? = nil) {
        
        UIView.transition(with: self.window!,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            
                            let oldState = UIView.areAnimationsEnabled
                            UIView.setAnimationsEnabled(false)
                            self.window!.rootViewController = viewController
                            UIView.setAnimationsEnabled(oldState)
                            
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
                    
                    let openDialogsControllerClosure = {
                        
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
                    
                    if self.window?.rootViewController == nil || !(self.window?.rootViewController is STTabBarViewController) {
                        
                        self.openMainController(completion: { completion in
                            
                            openDialogsControllerClosure()
                        })
                    }
                    else {
                        
                        openDialogsControllerClosure()
                    }
                }
                
                break
                
            case "post":
                
                if let newPost = Mapper<STNewPost>().map(JSON: payload) {
                    
                    let openPostDetailsControllerClosure = {
                        
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
                    
                    if self.window?.rootViewController == nil || !(self.window?.rootViewController is STTabBarViewController) {
                        
                        self.openMainController(completion: { completion in
                            
                            openPostDetailsControllerClosure()
                        })
                    }
                    else {
                        
                        openPostDetailsControllerClosure()
                    }
                }
                
                break
                
            default:
                break
            }
        }
    }
    
    fileprivate func checkSession(launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil,
                                  animation: Bool = false) {
        
        self.sessionChecked = false
        
        AppDelegate.appSettings.api.checkSession()
            
            .onSuccess { session in
                
                self.sessionChecked = true
                
                if !session.isExpired {
                    
                    // write session to db
                    session.writeToDB()
                    
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
                                
                                if let options = launchOptions {
                                    
                                    let key = UIApplicationLaunchOptionsKey("UIApplicationLaunchOptionsRemoteNotificationKey")
                                    
                                    if let payload = options[key] as? [String : Any] {
                                        
                                        self.pushNotificationHandler(payload: payload)
                                    }
                                    else {
                                        
                                        self.openMainController()
                                    }
                                }
                                else {
                                    
                                    self.openMainController()
                                }
                            }
                            
                            user.writeToDB()
                            user.updateUserImage()
                            
                            self.coldStart = false
                        })
                }
                else {
                    
                    // remove session from db
                    STSession.removeFromDB(by: STSession.self)
                    
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
            .onFailure { error in
            
                
            }
    }
    
    fileprivate func reachabilitySetup() {
        
        self.reachability?.whenReachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.toast.removeFromSuperview()
            }
        }
        
        self.reachability?.whenUnreachable = { reachability in
        
            DispatchQueue.main.async {
                
                self.showToast(message: "reachability_unreachable_text".localized)
            }
        }

        do {
            
            try reachability?.startNotifier()
        }
        catch {
            
            print("Unable to start notifier")
        }
    }
    
    fileprivate func showToast(message : String) {
        
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
}

