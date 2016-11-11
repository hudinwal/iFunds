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
            self.startImportFromBundledFile()
        })
    }
    func startImportFromBundledFile() {
        
        coreDataStack.writerContext.perform {
            let path = Bundle.main.url(forResource: "NAV_Few_Entries", withExtension: ".txt")
            if let aStreamReader = StreamReader(path: path!.path) {
                for line in aStreamReader {
                    if !line.contains(";") { continue }
                    print(line)
                    // Check if tuple exists
                    
                    // Get the scheme code from line
                    let componenets = line.components(separatedBy: ";")
                    let schemeCode = componenets[0]
                    
                    // Create a fetch request to find tuple with scheme code
                    let fetchRequest: NSFetchRequest<Scheme> = Scheme.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "schemeCode ==  %d", String(schemeCode))
                    fetchRequest.fetchLimit = 1
                    
                    // Do the fetching
                    var fetchItem: [Scheme]!
                    do { fetchItem = try self.coreDataStack.writerContext.fetch(fetchRequest) }
                    catch { print("Exception"); continue }
                    
                    // If tuple is found, fill it. Otherwise create a new one
                    if fetchItem.count > 0 {
                        fetchItem.first?.fill(charSeparatedString: line, separatorString: ";")
                    }
                    else {
                        let scheme = NSEntityDescription.insertNewObject(forEntityName: "Scheme", into: self.coreDataStack.writerContext) as! Scheme
                        scheme.fill(charSeparatedString: line, separatorString: ";")
                    }
                }
                aStreamReader.close()
                 do { try self.coreDataStack.writerContext.save() }
                 catch { print("Caught Someting") }
            }
        }
        
        setUpFetchController()
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
