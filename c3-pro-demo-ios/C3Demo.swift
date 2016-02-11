//
//  C3Demo.swift
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
import C3PRO
import SMART


protocol C3Demo {
	var title: String { get }
	var presentsModally: Bool { get }
	func viewController() throws -> UIViewController
	func viewController(callback: ((view: UIViewController?, error: ErrorType?) -> Void))
}

extension C3Demo {
	var presentsModally: Bool { return false }
	
	func viewController(callback: ((view: UIViewController?, error: ErrorType?) -> Void)) {
		do {
			callback(view: try self.viewController(), error: nil)
		}
		catch let error {
			callback(view: nil, error: error)
		}
	}
}


class C3DemoStudyIntro: C3Demo {
	
	var title: String {
		return "Study Overview"
	}
	
	func viewController() throws -> UIViewController {
		
		// instantiate from the "StudyIntro" storyboard, and apply the "StudyIntro.json" configuration
		let intro = try StudyIntroCollectionViewController.fromStoryboard("StudyIntro")
		intro.config = try StudyIntroConfiguration(json: "StudyIntro")
		
		// here you can configure what happens when the user taps the "Join Study" button. Usually this will start eligibility checking.
		intro.onJoinStudy = { controller in
			let alert = UIAlertController(title: "Join Study", message: "For next steps, look at “Eligibility & Consent”", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
			controller.presentViewController(alert, animated: true, completion: nil)
		}
		
		// for demo purposes we don't want to hide the navigation bar. If it is your front view controller you probably want this to stay true.
		intro.hidesNavigationBar = false
		return intro
	}
}


class C3DemoEligibility: C3Demo {
	
	var title: String {
		return "Eligibility & Consent"
	}
	
	var controller: ConsentController?
	
	func viewController() throws -> UIViewController {
		if nil == controller {
			controller = ConsentController(bundledContract: "Consent")
		}
		guard let controller = controller else {
			throw C3Error.BundleFileNotFound("Consent")
		}
		
		// providing a config is optional. It allows you to customize some "you're eligible" messages
		let config = try StudyIntroConfiguration(json:"StudyIntro")
		
		// if you let `onStartConsent` nil, consenting will automatically start if all eligibility criteria are met
		return controller.eligibilityStatusViewController(config, onStartConsent: nil)
	}
}


class C3DemoGeocoding: C3Demo {
	
	var title: String {
		return "Geocoding"
	}
	
	func viewController() throws -> UIViewController {
		return GeoTableViewController(style: .Grouped)
	}
}

