//
//  GeoTableViewController.swift
//  c3-pro-demo-ios
//
//  Created by Pascal Pfiffner on 17/12/15.
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


class GeoTableViewController: UITableViewController {
	
	lazy var geocoder = Geocoder()
	
	var lastAddress: Address?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ButtonCell")
		tableView.registerClass(GeoResultTableViewCell.self, forCellReuseIdentifier: "GeoCell")
	}
	
	
	// MARK: - Table View Data Source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0 == section ? 2 : 4
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if 0 == indexPath.section {
			let cell = tableView.dequeueReusableCellWithIdentifier("ButtonCell", forIndexPath: indexPath)
			if geocoder.isGeocoding {
				cell.textLabel?.text = "Geocoding..."
			}
			else if 0 == indexPath.row {
				cell.textLabel?.text = "Geocode"
			}
			else if 1 == indexPath.row {
				cell.textLabel?.text = "Geocode (HIPAA compliant)"
			}
			return cell
		}
		
		let cell = tableView.dequeueReusableCellWithIdentifier("GeoCell", forIndexPath: indexPath)
		if 0 == indexPath.row {
			cell.textLabel?.text = "Country"
			cell.detailTextLabel?.text = lastAddress?.country
		}
		else if 1 == indexPath.row {
			cell.textLabel?.text = "State"
			cell.detailTextLabel?.text = lastAddress?.state
		}
		else if 2 == indexPath.row {
			cell.textLabel?.text = "City"
			cell.detailTextLabel?.text = lastAddress?.city
		}
		else if 3 == indexPath.row {
			cell.textLabel?.text = "ZIP"
			cell.detailTextLabel?.text = lastAddress?.postalCode
		}
		return cell
	}
	
	
	// MARK: - Table View Delegate
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if 0 == indexPath.section {
			if !geocoder.isGeocoding {
				if 0 == indexPath.row {
					geocoder.currentAddress() { address, error in
						self.lastAddress = address
						if let error = error {
							self.c3_alert("Error Geocoding", message: "\(error)")
						}
						self.tableView.reloadData()
					}
				}
				else {
					geocoder.hipaaCompliantCurrentAddress() { address, error in
						self.lastAddress = address
						if let error = error {
							self.c3_alert("Error Geocoding", message: "\(error)")
						}
						self.tableView.reloadData()
					}
				}
				tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
			}
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}


class GeoResultTableViewCell: UITableViewCell {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: UITableViewCellStyle.Value1, reuseIdentifier: reuseIdentifier)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

