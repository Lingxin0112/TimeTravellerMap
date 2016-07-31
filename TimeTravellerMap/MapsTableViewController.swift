//
//  MapsTableTableViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 21/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import CoreData

class MapsTableViewController: UITableViewController {
    
    var managedContext: NSManagedObjectContext!
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Map", inManagedObjectContext: self.managedContext)
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedContext,
            sectionNameKeyPath: "area",
            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.searchBarStyle = .Minimal
        searchBar.delegate = self
        searchBar.placeholder = "search map"
        tableView.tableHeaderView = searchBar
        
        navigationItem.leftBarButtonItem = editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    // Functions
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error: \(error)")
        }
    }
    
    func filterMapForSearch(searchText: String, scope: String = "All") {
        NSFetchedResultsController.deleteCacheWithName("Maps")
        if searchText.isEmpty {
            fetchedResultsController.fetchRequest.predicate = nil
        } else {
            NSFetchedResultsController.deleteCacheWithName("Maps")
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name contains[cd] %@", searchText)
        }
        
        performFetch()
        tableView.reloadData()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchedResultsController.sectionIndexTitles
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MapCell", forIndexPath: indexPath)

        let map = fetchedResultsController.objectAtIndexPath(indexPath) as! Map
        cell.textLabel?.text = map.name
        cell.detailTextLabel?.text = map.date

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let map = fetchedResultsController.objectAtIndexPath(indexPath) as! Map
            managedContext.deleteObject(map)
            
            do {
                try managedContext.save()
            } catch {
                fatalError("Error: \(error)")
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddMap" {
            let nvController = segue.destinationViewController as! UINavigationController
            let controller = nvController.topViewController as! AddMapViewController
            controller.managedContext = managedContext
        } else if segue.identifier == "ShowMapDetails" {
            let controller = segue.destinationViewController as! MapDetailsViewController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let map = fetchedResultsController.objectAtIndexPath(indexPath) as! Map
                controller.managedContext = managedContext
                controller.map = map
            }
        }
    }

}

extension MapsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterMapForSearch(searchController.searchBar.text!)
    }
}

extension MapsTableViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
}

extension MapsTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("MapTableViewController changed")
        tableView.beginUpdates()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            print("MapTableViewController insert")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            print("MapTableViewController delete")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) {
                let map = controller.objectAtIndexPath(indexPath!) as! Map
                cell.textLabel?.text = map.name
                cell.detailTextLabel?.text = map.date
//                cell.configureCellForEvent(event)
            }
            print("MapTableViewController update")
        case .Move:
            print("MapTableViewController move")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex)
        switch type {
        case .Insert:
            print("MapTableViewController section insert")
            tableView.insertSections(indexSet, withRowAnimation: .Fade)
        case .Delete:
            print("MapTableViewController section delete")
            tableView.deleteSections(indexSet, withRowAnimation: .Fade)
        case .Update:
            print("MapTableViewController section update")
        case .Move:
            print("MapTableViewController section move")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("MapTableViewController changed finished")
        tableView.endUpdates()
    }
}

