//
//  C3Demo.swift
//  c3-pro-demo-ios
//
//  Created by Pascal Pfiffner on 12/3/15.
//  Copyright © 2015 Boston Children's Hospital. All rights reserved.
//

import UIKit
import C3PRO


protocol C3Demo {
	var title: String { get }
	var presentsModally: Bool { get }
	func viewController() throws -> UIViewController
}

extension C3Demo {
	var presentsModally: Bool { return false }
}


class C3DemoStudyIntro: C3Demo {
	
	var title: String {
		return "Study Overview"
	}
	
	func viewController() throws -> UIViewController {
		let storyboard = UIStoryboard(name: "StudyIntro", bundle: nil)
		
		// Instantiate `StudyIntroCollectionViewController` from the "StudyIntro" storyboard, and apply the "StudyIntro.json" configuration
		if let intro = storyboard.instantiateInitialViewController() as? StudyIntroCollectionViewController {
			intro.config = try StudyIntroConfiguration(json: "StudyIntro")
			intro.hidesNavigationBar = false		// for demo purposes we don't want to hide the navigation bar. If it is your front view controller you probably want this to stay true.
			
			// here you can configure what happens when the user taps the "Join Study" button. Usually this will start eligibility checking.
			intro.onJoinStudy = { controller in
				let alert = UIAlertController(title: "Join Study", message: "For next steps, look at “Eligibility & Consent”", preferredStyle: .Alert)
				alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
				controller.presentViewController(alert, animated: true, completion: nil)
			}
			
			return intro
		}
		throw C3Error.InvalidStoryboard("Expecting `StudyIntroCollectionViewController` from our 'StudyIntro' storyboard")
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
			controller = ConsentController(bundledContract: "Consent")
		}
		guard let controller = controller else {
			throw C3Error.BundleFileNotFound("Consent")
		}
		
		// instantiate a consent view controller that simply produces an alert when consenting and when declining; ignore the window.rootViewController hack, it's demo time!
		return try controller.consentViewController(
			onUserDidConsent: { taskController, result in
				let pdf = controller.dynamicType.signedConsentPDFURL()
				taskController.dismissViewControllerAnimated(true, completion: nil)
				taskController.presentingViewController?.c3_alert("Consented", message: "The signed PDF is at «\(pdf)»")
			},
			onUserDidDecline: { taskController in
				taskController.dismissViewControllerAnimated(true, completion: nil)
				taskController.presentingViewController?.c3_alert("Declined!", message: "You did not consent")
		})
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
			
			dispatch_async(dispatch_get_main_queue()) {
				pdfVC.loadPDFDataFrom(url)
			}
			return pdfVC
		}
		else {
			let alert = UIAlertController(title: "Signed Consent", message: "The signed consent is available once you've gone through consenting, agreed to and signed the consent", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
			return alert
		}
	}
}

