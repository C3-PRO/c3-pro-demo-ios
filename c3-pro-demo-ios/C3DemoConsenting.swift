//
//  C3DemoConsenting.swift
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


class C3DemoConsenting: C3Demo {
	
	var title: String {
		return "Consent Only"
	}
	
	var presentsModally: Bool {
		return true
	}
	
	var controller: ConsentController?
	
	func viewController() throws -> UIViewController {
		if nil == controller {
			controller = try ConsentController(bundledContract: "Consent")
		}
		guard let controller = controller else {
			throw C3Error.bundleFileNotFound("Consent")
		}
		
		// instantiate a consent view controller that simply produces an alert when consenting and when declining
		return try controller.consentViewController(
			onUserDidConsent: { taskController, result in
				let pdf = type(of: controller).signedConsentPDFURL()
				taskController.dismiss(animated: true)
				taskController.presentingViewController?.c3_alert("Consented", message: "The signed PDF is at «\(pdf)»")
			},
			onUserDidDecline: { taskController in
				taskController.dismiss(animated: true)
				taskController.presentingViewController?.c3_alert("Declined!", message: "You did not consent")
		})
	}
}


class C3DemoOverviewEligibilityConsent: C3Demo {
	
	var title: String {
		return "Overview & Eligibility & Consent"
	}
	
	var controller: ConsentController?
	
	func viewController() throws -> UIViewController {
		if nil == controller {
			controller = try ConsentController(bundledContract: "Consent")		// we want to hold on to our controller
		}
		guard let controller = controller else {
			throw C3Error.bundleFileNotFound("Consent")
		}
		
		// instantiate from the "StudyIntro" storyboard, and apply the "StudyIntro.json" configuration
		let intro = try StudyIntroCollectionViewController.fromStoryboard(named: "StudyIntro")
		intro.config = try StudyIntroConfiguration(json:"StudyIntro")
		intro.onJoinStudy = { viewController in
			
			// subscribe our app delegate to the did-consent notification; we simply pop out, in real life you want to start app setup (PIN, permissions)
			let center = NotificationCenter.default
			center.addObserver(UIApplication.shared.delegate!, selector: Selector("userDidConsent"), name: C3UserDidConsentNotification, object: nil)
			
			// show eligibility view controller when the user wants to your your study
			let elig = controller.eligibilityStatusViewController(intro.config)
			if let navi = intro.navigationController {
				navi.pushViewController(elig, animated: true)
			}
			else {
				// you did not put the intro view controller on a navigation controller!
			}
		}
		
		// for demo purposes we don't want to hide the navigation bar. If it is your front view controller you probably want this to stay true.
		intro.hidesNavigationBar = false
		return intro
	}
}


class C3DemoSignedConsentReview: C3Demo {
	
	var title: String {
		return "Signed Consent Review"
	}
	
	var presentsModally: Bool {
		return (nil == ConsentController.signedConsentPDFURL())
	}
	
	func viewController() throws -> UIViewController {
		
		// return a `PDFViewController` that loads the signed PDF, if it's there.
		if let url = ConsentController.signedConsentPDFURL() {
			let pdfVC = PDFViewController()
			pdfVC.title = NSLocalizedString("Consent", comment: "")
			
			DispatchQueue.main.async {
				pdfVC.loadPDFDataFrom(url)
			}
			return pdfVC
		}
		else {
			let alert = UIAlertController(title: "Signed Consent", message: "The signed consent is available once you've gone through consenting, agreed to and signed the consent", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			return alert
		}
	}
}

