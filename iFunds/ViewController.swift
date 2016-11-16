//
//  ViewController.swift
//  iFunds
//
//  Created by Dinesh Kumar on 15/10/16.
//  Copyright © 2016 Organization. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var coreDataStack: CoreDataStack!
    var fetchRequestController: NSFetchedResultsController<Scheme>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = "Mutual Funds"
        
        setUpCoreDataStack()
    }
    
    func setUpCoreDataStack() {
        coreDataStack = CoreDataStack(callBack: {
            print("Core Data Setup Done")
            self.setUpFetchController()
            self.startImportFromBundledFile()
        })
    }
    func startImportFromBundledFile() {
        coreDataStack.newBatchOperationContext { (context:NSManagedObjectContext?) in
            guard let context = context else { return }
            context.perform {
                let path = Bundle.main.url(forResource: "NAV", withExtension: ".txt")
                if let aStreamReader = StreamReader(path: path!.path) {
                    
                    _ = aStreamReader.nextLine()
                    
                    var schemeType: String = ""
                    var schemeFundHouse:FundHouse?
                    for line in aStreamReader
                    {
                        if line == "\r" {
                            continue
                        }
                        if line.contains("("), line.contains(")"),!line.contains(";") {
                            schemeType = line
                            continue
                        }
                        if !line.contains(";") {
                            if schemeFundHouse != nil {
                                if let fundHouseName = schemeFundHouse?.name, fundHouseName != line {
                                    
                                    // Create a fetch request to find tuple with scheme code
                                    let fetchRequest: NSFetchRequest<FundHouse> = FundHouse.fetchRequest()
                                    fetchRequest.predicate = NSPredicate(format: "name ==  %@", line)
                                    fetchRequest.fetchLimit = 1
                                    
                                    // Do the fetching
                                    var fetchItem: [FundHouse]!
                                    do { fetchItem = try context.fetch(fetchRequest) }
                                    catch { print("Exception"); continue }
                                    
                                    // If tuple is found, fill it. Otherwise create a new one
                                    if fetchItem.count > 0 {
                                        schemeFundHouse = fetchItem.first
                                    }
                                    else {
                                        schemeFundHouse = NSEntityDescription.insertNewObject(forEntityName: "FundHouse", into: context) as? FundHouse
                                        schemeFundHouse?.name = line
                                    }
                                }
                            }
                            else {
                                // Create a fetch request to find tuple with scheme code
                                let fetchRequest: NSFetchRequest<FundHouse> = FundHouse.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "name ==  %@", line)
                                fetchRequest.fetchLimit = 1
                                
                                // Do the fetching
                                var fetchItem: [FundHouse]!
                                do { fetchItem = try context.fetch(fetchRequest) }
                                catch { print("Exception"); continue }
                                
                                // If tuple is found, fill it. Otherwise create a new one
                                if fetchItem.count > 0 {
                                    schemeFundHouse = fetchItem.first
                                }
                                else {
                                    schemeFundHouse = NSEntityDescription.insertNewObject(forEntityName: "FundHouse", into: context) as? FundHouse
                                    schemeFundHouse?.name = line
                                }
                            }
                        }
                        else {
                            let scheme = NSEntityDescription.insertNewObject(forEntityName: "Scheme", into: context) as! Scheme
                            scheme.fill(charSeparatedString: line, separatorString: ";")
                            scheme.schemeType = schemeType
                            scheme.belongsToFundHouse = schemeFundHouse
                        }
                    }
                    aStreamReader.close()
                    do {
                        try context.save()
                        self.fetchRequestController?.managedObjectContext.perform {
                            do { try self.fetchRequestController?.performFetch() }
                            catch { print("Error") }
                            self.tableView.reloadData()
                        }
                    }
                    catch { print("Error") }
                }
            }
        }
    }
    
    func setUpFetchController() {
        
        let fetchRequest: NSFetchRequest<Scheme> = Scheme.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "schemeName", ascending: true)]
        fetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchRequestController?.delegate = self
        
        do {
            try fetchRequestController?.performFetch()
            self.tableView.reloadData()
        }
        catch {
            print("Caught Something")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (fetchRequestController?.sections?.count) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchRequestController?.sections
        if let sections = sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        else { return 0 }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_ID", for: indexPath)
        configure(cell, forIndexPath: indexPath)
        return cell;
    }
    
    func configure(_ cell:UITableViewCell, forIndexPath:IndexPath) {
        guard let fetchRequestController = fetchRequestController else { return }
        let scheme = fetchRequestController.object(at: forIndexPath)
        cell.textLabel?.text = scheme.schemeName
        cell.detailTextLabel?.text =  String(scheme.schemeCode)
    }
}

extension TableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var itemsCount = 0
        let sections = controller.sections
        if let sections = sections {
            let sectionInfo = sections[0]
            itemsCount = sectionInfo.numberOfObjects
        }
        
        self.navigationItem.title = "\(itemsCount) Funds"
        
        switch type {
        case .insert:
            tableView.insertRows(at:[newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at:[indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at:[indexPath!], with: .fade)
            tableView.insertRows(at:[newIndexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) {
                configure(cell, forIndexPath: indexPath!)
            }
        }
    }
}
