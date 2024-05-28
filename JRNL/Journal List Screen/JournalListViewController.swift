//
//  ViewController.swift
//  JRNL
//
//  Created by Jungman Bae on 5/7/24.
//

import UIKit
import SwiftData

class JournalListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating {
    // MARK: - Properties
    @IBOutlet var collectionView: UICollectionView!
    let search = UISearchController(searchResultsController: nil)
    var journalEntries: [JournalEntry] = []
    var filteredTableData: [JournalEntry] = []
    var container: ModelContainer?
    var context: ModelContext?
    let descriptor = FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor<JournalEntry>(\.dateString)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        SharedData.shared.loadJournalEntriesData()
        guard let _container = try? ModelContainer(for: JournalEntry.self) else {
            fatalError("Could not initialize Container")
        }
        container = _container
        context = ModelContext(_container)
        fetchJournalEntries()
        
        setupCollectionView()
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search titles"
        navigationItem.searchController = search
    }

    // 회전할때 사이즈를 재설정
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func setupCollectionView() {
        // 초기값을 주기 위해
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 10
        collectionView.collectionViewLayout = flowLayout
    }
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if search.isActive {
            return self.filteredTableData.count
        } else {
//            return SharedData.shared.numberOfJournalEntries()
            return self.journalEntries.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let journalCell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCell", for: indexPath) as! JournalListCollectionViewCell
        
        let journalEntry: JournalEntry
        if self.search.isActive {
            journalEntry = filteredTableData[indexPath.row]
        } else {
//            journalEntry = SharedData.shared.getJournalEntry(index: indexPath.row)
            journalEntry = journalEntries[indexPath.row]
        }
        if let photoData = journalEntry.photoData {
            journalCell.photoImageView.image = UIImage(data: photoData)
        }
        journalCell.dateLabel.text = journalEntry.dateString
        journalCell.titleLabel.text = journalEntry.entryTitle
        return journalCell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // item button 을 long press 해서 팝업이 뜨면 나오는 메뉴를 구성
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (elements) -> UIMenu? in
            let delete = UIAction(title: "Delete") { [weak self] (action) in
                if let search = self?.search, search.isActive,
                   let selectedJournalEntry = self?.filteredTableData[indexPath.item] {
                    self?.filteredTableData.remove(at: indexPath.item)
//                    SharedData.shared.removeSelectedJournalEntry(selectedJournalEntry)
                    self?.context?.delete(selectedJournalEntry)
                } else {
//                    SharedData.shared.removeJournalEntry(index: indexPath.item)
                    if let selectedJournalEntry = self?.journalEntries[indexPath.item] {
                        self?.journalEntries.remove(at: indexPath.item)
                        self?.context?.delete(selectedJournalEntry)
                    }
                }
//                SharedData.shared.saveJournalEntriesData()
                collectionView.reloadData()
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [delete])
        }
        return config
    }
    // 아이템의 크기를 동적으로 계산
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var columns: CGFloat
        // 가로축 사이즈 체크
        if (traitCollection.horizontalSizeClass == .compact) {
            columns = 1
        } else {
            columns = 2
        }
        let viewWidth = collectionView.frame.width
        let inset = 10.0 // padding
        let contentWidth = viewWidth - inset * (columns + 1)
        let cellWidth = contentWidth / columns
        let cellHeight = 90.0
        return CGSize(width: cellWidth, height: cellHeight)
        
    }
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        
        filteredTableData.removeAll()
//        filteredTableData = SharedData.shared.getAllJournalEntries().filter { journalEntry in
        filteredTableData = journalEntries.filter { journalEntry in
            journalEntry.entryTitle.lowercased().contains(searchBarText.lowercased())
        }
        self.collectionView.reloadData()
    }
    
    // MARK: - Methods
    func fetchJournalEntries() {
        if let journalEntries = try? context?.fetch(descriptor) {
            self.journalEntries = journalEntries
        }
    }
    
    @IBAction func unwindNewEntryCancel(segue: UIStoryboardSegue) {
        
    }
    @IBAction func unwindNewEntrySave(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? AddJournalEntryViewController,
           let newJournalEntry = sourceViewController.newJournalEntry {
//            SharedData.shared.addJournalEntry(newJournalEntry: newJournalEntry)
//            SharedData.shared.saveJournalEntriesData()
            self.context?.insert(newJournalEntry)
//            self.search.searchBar.isHidden = false
            fetchJournalEntries()
            collectionView.reloadData()
        } else {
            print("No Entry or Controller")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "entryDetail" else {
            return
        }
        guard let journalEntryDetailViewController = segue.destination as? JournalEntryDetailViewController,
              let selectedJournalEntryCell = sender as? JournalListCollectionViewCell,
              let indexPath = collectionView.indexPath(for: selectedJournalEntryCell) else {
            fatalError("Could not get indexPath")
        }
        let selectedJournalEntry: JournalEntry
        if self.search.isActive {
            selectedJournalEntry = filteredTableData[indexPath.row]
        } else {
//            selectedJournalEntry = SharedData.shared.getJournalEntry(index: indexPath.row)
            selectedJournalEntry = journalEntries[indexPath.row]
        }
        journalEntryDetailViewController.selectedJournalEntry = selectedJournalEntry
    }

}

