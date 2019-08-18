//
//  HistoryViewController.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/18/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import UIKit
import CoreData

final class HistoryViewController: UIViewController {
    private var dataSource: TableViewDataSource<HistoryViewController>?
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60.0
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "HistoryCell", bundle: Bundle.main), forCellReuseIdentifier: "HistoryCell")
        
        guard let moc = PersistentStoreManager.shared.moc
            else { return }
        let request = Trip.sortedFetchRequest
        request.fetchBatchSize = 20
        request.returnsObjectsAsFaults = false
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: "HistoryCell", fetchedResultsController: frc, delegate: self)
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HistoryDetailViewController") as? HistoryDetailViewController else { fatalError() }
        vc.trip = dataSource?.fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension HistoryViewController: TableViewDataSourceDelegate {
    func configure(_ cell: HistoryCell, for object: Trip) {
        cell.setup(session: object)
    }
    
    func notifyEmptyData(isEmpty: Bool) {
        
    }
}
