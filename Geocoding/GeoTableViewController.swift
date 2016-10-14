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
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ButtonCell")
		tableView.register(GeoResultTableViewCell.self, forCellReuseIdentifier: "GeoCell")
	}
	
	
	// MARK: - Table View Data Source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0 == section ? 2 : 4
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if 0 == (indexPath as NSIndexPath).section {
			let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath)
			if geocoder.isGeocoding {
				cell.textLabel?.text = "Geocoding..."
			}
			else if 0 == (indexPath as NSIndexPath).row {
				cell.textLabel?.text = "Geocode"
			}
			else if 1 == (indexPath as NSIndexPath).row {
				cell.textLabel?.text = "Geocode (HIPAA compliant)"
			}
			return cell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "GeoCell", for: indexPath)
		if 0 == (indexPath as NSIndexPath).row {
			cell.textLabel?.text = "Country"
			cell.detailTextLabel?.text = lastAddress?.country
		}
		else if 1 == (indexPath as NSIndexPath).row {
			cell.textLabel?.text = "State"
			cell.detailTextLabel?.text = lastAddress?.state
		}
		else if 2 == (indexPath as NSIndexPath).row {
			cell.textLabel?.text = "City"
			cell.detailTextLabel?.text = lastAddress?.city
		}
		else if 3 == (indexPath as NSIndexPath).row {
			cell.textLabel?.text = "ZIP"
			cell.detailTextLabel?.text = lastAddress?.postalCode
		}
		return cell
	}
	
	
	// MARK: - Table View Delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if 0 == (indexPath as NSIndexPath).section {
			if !geocoder.isGeocoding {
				if 0 == (indexPath as NSIndexPath).row {
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
				tableView.reloadSections(IndexSet(integer: 0), with: .none)
			}
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
}


class GeoResultTableViewCell: UITableViewCell {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

