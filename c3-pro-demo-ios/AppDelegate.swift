//
//  AppDelegate.swift
//  c3-pro-demo-ios
//
//  Created by Pascal Pfiffner on 12/3/15.
//  Copyright © 2015 Boston Children's Hospital. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		let splitViewController = self.window!.rootViewController as! UISplitViewController
		let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
		navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
		splitViewController.delegate = self
		return true
	}
	
	
	// MARK: - Consenting
	
	func userDidConsent() {
		print("You were just notified that the user consented. Now you want to show your app's setup process (set PIN, grant permissions).")
		let splitViewController = self.window!.rootViewController as! UISplitViewController
		let navi = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
		navi.popToRootViewControllerAnimated(true)
	}
	

	// MARK: - Split view

	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
	    guard secondaryViewController is UINavigationController else { return false }
		// Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
		return true
	}
}


extension UIViewController {
	func c3_alert(title: String, message: String, animated: Bool = true) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
		presentViewController(alert, animated: animated, completion: nil)
	}
}

