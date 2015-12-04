//
//  C3Demo.swift
//  c3-pro-demo-ios
//
//  Created by Pascal Pfiffner on 12/3/15.
//  Copyright © 2015 Boston Children's Hospital. All rights reserved.
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
		
		// instantiate a consent view controller that simply produces an alert when consenting and when declining
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


class C3DemoOverviewEligibilityConsent: C3Demo {
	
	var title: String {
		return "Overview & Eligibility & Consent"
	}
	
	var controller: ConsentController?
	
	func viewController() throws -> UIViewController {
		if nil == controller {
			controller = ConsentController(bundledContract: "Consent")		// we want to hold on to our controller
		}
		guard let controller = controller else {
			throw C3Error.BundleFileNotFound("Consent")
		}
		
		// instantiate from the "StudyIntro" storyboard, and apply the "StudyIntro.json" configuration
		let intro = try StudyIntroCollectionViewController.fromStoryboard("StudyIntro")
		intro.config = try StudyIntroConfiguration(json:"StudyIntro")
		intro.onJoinStudy = { viewController in
			
			// subscribe our app delegate to the did-consent notification; we simply pop out, in real life you want to start app setup (PIN, permissions)
			let center = NSNotificationCenter.defaultCenter()
			center.addObserver(UIApplication.sharedApplication().delegate!, selector: "userDidConsent", name: C3UserDidConsentNotification, object: nil)
			
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


class C3DemoQuestionnaire: C3Demo {
	
	var title: String {
		return "Survey / Questionnaire"
	}
	
	var presentsModally: Bool {
		return true
	}
	
	lazy var controller = QuestionnaireController()
	
	func viewController() throws -> UIViewController {
		throw C3Error.NotImplemented("Must use asynchronous method")
	}
	
	func viewController(callback: ((view: UIViewController?, error: ErrorType?) -> Void)) {
		do {
			// get the questionnaire; to download one from a FHIR server you can use `Questionnaire.readFrom(...)` -- you probably want to use a cached one!
			controller.questionnaire = (try NSBundle.mainBundle().fhir_bundledResource("Questionnaire-choices") as! Questionnaire)
			
			controller.whenCompleted = { viewController, answers in
				viewController.dismissViewControllerAnimated(true, completion: nil)
				if let answers = answers {
					// you could now use the following to push the answers to a SMART on FHIR server:
					// answers.create(<# smart.server #>) { error in [...] }
					viewController.presentingViewController?.c3_alert("Survey Completed", message: "Survey is complete, answers have been logged to console")
					print("\(answers):\n\(answers.asJSON())")
				}
			}
			
			controller.whenCancelledOrFailed = { viewController, error in
				viewController.dismissViewControllerAnimated(true, completion: nil)
				if let error = error {
					viewController.presentingViewController?.c3_alert("Error", message: "\(error)")
				}
			}
			
			// prepare the questionnaire: this downloads referenced values if necessary, hence the asynchronous callback
			controller.prepareQuestionnaireViewController() { viewController, error in
				callback(view: viewController, error: error)
			}
		}
		catch let error {
			callback(view: nil, error: error)
		}
	}
}

