//
//  Map+CoreDataProperties.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 21/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Map {

    @NSManaged var name: String?
    @NSManaged var date: String?
    @NSManaged var area: String?

}
