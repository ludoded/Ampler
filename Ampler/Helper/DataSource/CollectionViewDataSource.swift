//
//  CollectionViewDataSource.swift
//  BoweryRes
//
//  Created by Haik Ampardjian on 3/1/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import UIKit
import CoreData

protocol CollectionViewDataSourceDelegate: class {
    associatedtype Object: NSFetchRequestResult
    associatedtype Cell: UICollectionViewCell
    func configure(_ cell: Cell, for object: Object)
    func notifyEmptyData(isEmpty: Bool)
}

final class CollectionViewDataSource<Delegate: CollectionViewDataSourceDelegate>: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    typealias Object = Delegate.Object
    typealias Cell = Delegate.Cell
    
    required init(collectionView: UICollectionView, cellIdentifier: String, fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        self.collectionView = collectionView
        self.cellIdentifier = cellIdentifier
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        collectionView.dataSource = self
        collectionView.reloadData()
        
        if (fetchedResultsController.fetchedObjects?.isEmpty ?? false) {
            delegate.notifyEmptyData(isEmpty: true)
        }
    }
    
    var selectedObject: [Object]? {
        guard let indexPath = collectionView.indexPathsForSelectedItems else { return nil }
        return objectAtIndexPath(indexPath)
    }
    
    func objectAtIndexPath(_ indexPaths: [IndexPath]) -> [Object] {
        return indexPaths.map({ fetchedResultsController.object(at: $0) })
    }
    
    func reconfigureFetchRequest(_ configure: (NSFetchRequest<Object>) -> ()) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: fetchedResultsController.cacheName)
        configure(fetchedResultsController.fetchRequest)
        do { try fetchedResultsController.performFetch() } catch { fatalError("fetch request failed") }
        collectionView.reloadData()
    }
    
    // MARK: Private
    fileprivate let collectionView: UICollectionView
    let fetchedResultsController: NSFetchedResultsController<Object>
    fileprivate weak var delegate: Delegate!
    fileprivate let cellIdentifier: String
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let object = fetchedResultsController.object(at: indexPath)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? Cell
            else { fatalError("Unexpected cell type at \(indexPath)") }
        delegate.configure(cell, for: object)
        return cell
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        collectionView.performBatchUpdates({
            switch type {
            case .insert:
                guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
                self.collectionView.insertItems(at: [indexPath])
            case .update:
                guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
                let object = objectAtIndexPath([indexPath]).first!
                guard let cell = collectionView.cellForItem(at: indexPath) as? Cell else { break }
                delegate.configure(cell, for: object)
            case .move:
                guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
                guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
                collectionView.deleteItems(at: [indexPath])
                collectionView.insertItems(at: [newIndexPath])
            case .delete:
                guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
                collectionView.deleteItems(at: [indexPath])
            }
        }, completion: nil)
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let isEmpty = fetchedResultsController.fetchedObjects?.isEmpty {
            delegate.notifyEmptyData(isEmpty: isEmpty)
        }
    }
}
