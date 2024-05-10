//
//  ViewController.swift
//  JRNL
//
//  Created by Jungman Bae on 5/7/24.
//

import UIKit

class JournalListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath)
    }
    
    @IBAction func unwindNewEntryCancel(segue: UIStoryboardSegue) {
        
    }
}

