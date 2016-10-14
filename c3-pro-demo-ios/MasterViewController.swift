//
//  MasterViewController.swift
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


class MasterViewController: UITableViewController {
	
	var demos = [[C3Demo]]()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// create demos
		self.demos = [[
			C3DemoStudyIntro(),
			C3DemoEligibility(),
			C3DemoConsenting(),
			C3DemoOverviewEligibilityConsent(),
			C3DemoSignedConsentReview(),
		],[
			C3DemoQuestionnaireChoices(),
			C3DemoQuestionnaireTextValues(),
			C3DemoQuestionnaireDates(),
		],[
			C3DemoSystemServices(),
		],[
			C3DemoGeocoding(),
		]]
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}
	
	
	// MARK: - Segues
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if "showDetail" == identifier {
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let demo = demos[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
				return !demo.presentsModally
			}
		}
		return true
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if "showDetail" == segue.identifier {
		    if let indexPath = self.tableView.indexPathForSelectedRow {
				let demo = demos[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
				do {
					let viewController = try demo.viewController()
					if let navi = segue.destination as? UINavigationController {
						navi.viewControllers = [viewController]
					}
					else {
						throw C3Error.invalidStoryboard("Need navigation controller as root detail view controller")
					}
				}
				catch let error {
					c3_alert("Something's Wrong", message: "\(error)")
				}
		    }
		}
	}
	
	
	// MARK: - Table View
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return demos.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return demos[section].count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let demo = demos[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
		cell.textLabel?.text = demo.title
		cell.accessoryType = demo.presentsModally ? .none : .disclosureIndicator
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let demo = demos[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
		if demo.presentsModally {
			demo.viewController() { viewController, error in
				if let viewController = viewController {
					self.present(viewController, animated: true, completion: nil)
				}
				else if let error = error {
					self.c3_alert("Something's Wrong", message: "\(error)")
				}
			}
		}
	}
}

