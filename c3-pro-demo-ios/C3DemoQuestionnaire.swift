//
//  C3DemoQuestionnaire.swift
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


class C3DemoQuestionnaire: C3Demo {
	
	private var type: String {
		return "nil"
	}
	
	var title: String {
		return "Survey / Questionnaire (\(type))"
	}
	
	var presentsModally: Bool {
		return true
	}
	
	var controller: QuestionnaireController?
	
	func viewController() throws -> UIViewController {
		throw C3Error.NotImplemented("Must use asynchronous method")
	}
	
	func viewController(callback: ((view: UIViewController?, error: ErrorType?) -> Void)) {
		do {
			// get the questionnaire; to download one from a FHIR server you can use `Questionnaire.readFrom(...)` -- you probably want to use a cached one!
			if nil == controller {
				let questionnaire = try NSBundle.mainBundle().fhir_bundledResource("Questionnaire-\(type)", type: Questionnaire.self)
				controller = QuestionnaireController(questionnaire: questionnaire)
				controller?.logger = OAuth2DebugLogger()
			}
			
			controller!.whenCompleted = { viewController, answers in
				viewController.dismissViewControllerAnimated(true, completion: nil)
				if let answers = answers {
					// you could now use the following to push the answers to a SMART on FHIR server:
					// answers.create(<# smart.server #>) { error in [...] }
					viewController.presentingViewController?.c3_alert("Survey Completed", message: "Survey is complete, answers have been logged to console")
					do {
						let data = try NSJSONSerialization.dataWithJSONObject(answers.asJSON(), options: .PrettyPrinted)
						let json = String(data: data, encoding: NSUTF8StringEncoding)
						print("\(answers):\n\(json ?? "")")
					}
					catch let error {
						print("Failed to serialize response as JSON: \(error)")
					}
				}
			}
			
			controller!.whenCancelledOrFailed = { viewController, error in
				viewController.dismissViewControllerAnimated(true, completion: nil)
				if let error = error {
					viewController.presentingViewController?.c3_alert("Error", message: "\(error)")
				}
			}
			
			// prepare the questionnaire: this downloads referenced values if necessary, hence the asynchronous callback
			controller!.prepareQuestionnaireViewController() { viewController, error in
				callback(view: viewController, error: error)
			}
		}
		catch let error {
			callback(view: nil, error: error)
		}
	}
}


class C3DemoQuestionnaireChoices: C3DemoQuestionnaire {
	
	override var type: String {
		return "choices"
	}
}


class C3DemoQuestionnaireTextValues: C3DemoQuestionnaire {
	
	override var type: String {
		return "textvalues"
	}
}


class C3DemoQuestionnaireDates: C3DemoQuestionnaire {
	
	override var type: String {
		return "dates"
	}
}

