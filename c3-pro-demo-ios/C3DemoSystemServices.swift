//
//  C3DemoSystemServices.swift
//  c3-pro-demo-ios
//
//  Created by Pascal Pfiffner on 2/11/16.
//  Copyright © 2016 Boston Children's Hospital. All rights reserved.
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
import HealthKit


class C3DemoSystemServices: C3Demo {
	
	var title: String {
		return "System Services"
	}
	
	func desiredSystemServices() -> [SystemService] {
		
		// notification categories; usually you have a method that returns fully configured categories that you also use when actually registering
		let notificationCategory = UIMutableUserNotificationCategory()
		notificationCategory.identifier = "delayable"
		var notificationSet = Set<UIUserNotificationCategory>()
		notificationSet.insert(notificationCategory)
		
		// we want to read sex and DOB from HealthKit (characteristics) and some measurements (quantities)
		let hkCRead = Set<HKCharacteristicType>([
			HKCharacteristicType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
			HKCharacteristicType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
			])
		let hkQRead = Set<HKQuantityType>([
			HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
			HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
			HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
			HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)!,
			HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
			])
		let hkTypes = HealthKitTypes(readCharacteristics: hkCRead, readQuantities: hkQRead, writeQuantities: Set())
		
		return [
			SystemService.localNotifications(notificationSet),
			SystemService.coreMotion,
			SystemService.geoLocationWhenUsing("Access to your current location allows us to determine the state you live in so we can detect local disease trends."),
			SystemService.healthKit(hkTypes),
		]
	}
	
	func viewController() throws -> UIViewController {
		let vc = SystemPermissionTableViewController(style: .plain)
		vc.services = desiredSystemServices()
		return vc
	}
}
