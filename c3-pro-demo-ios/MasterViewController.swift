//
//  MasterViewController.swift
//  c3-pro-demo-ios
//
//  Created by Pascal Pfiffner on 12/3/15.
//  Copyright © 2015 Boston Children's Hospital. All rights reserved.
//

import UIKit
import C3PRO


class MasterViewController: UITableViewController {
	
	var demos = [C3Demo]()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// create demos
		self.demos = [
			C3DemoStudyIntro(),
			C3DemoEligibility(),
			C3DemoConsenting(),
			C3DemoOverviewEligibilityConsent(),
			C3DemoSignedConsentReview(),
		]
	}
	
	override func viewWillAppear(animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
		super.viewWillAppear(animated)
	}
	
	
	// MARK: - Segues
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if "showDetail" == identifier {
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let demo = demos[indexPath.row]
				return !demo.presentsModally
			}
		}
		return true
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if "showDetail" == segue.identifier {
		    if let indexPath = self.tableView.indexPathForSelectedRow {
		        let demo = demos[indexPath.row]
				do {
					let viewController = try demo.viewController()
					if let navi = segue.destinationViewController as? UINavigationController {
						navi.viewControllers = [viewController]
					}
					else {
						throw C3Error.InvalidStoryboard("Need navigation controller as root detail view controller")
					}
				}
				catch let error {
					c3_alert("Something's Wrong", message: "\(error)")
				}
		    }
		}
	}
	
	
	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return demos.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		let demo = demos[indexPath.row]
		cell.textLabel?.text = demo.title
		cell.accessoryType = demo.presentsModally ? .None : .DisclosureIndicator
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let demo = demos[indexPath.row]
		if demo.presentsModally {
			do {
				let viewController = try demo.viewController()
				presentViewController(viewController, animated: true, completion: nil)
			}
			catch let error {
				c3_alert("Something's Wrong", message: "\(error)")
			}
		}
	}
}

