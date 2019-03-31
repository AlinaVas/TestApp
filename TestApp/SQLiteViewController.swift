//
//  ViewController.swift
//  TestApp
//
//  Created by Alina FESYK on 3/29/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import UIKit

class SQLiteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    var presenter = SQLitePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDelegate = self
        searchTextField.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 30
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        if addTextField.text != "" {
            presenter.addItem(with: addTextField.text!)
        }
        addTextField.resignFirstResponder()
    }
}

extension SQLiteViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell") as? ContentTableViewCell {
            cell.contentLabel.text = presenter.getContent(for: indexPath.row)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("commit editing style")
            presenter.deleteItem(at: indexPath.row)
            if tableView.numberOfRows(inSection: indexPath.section) > 1 {
                print("delete row")
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                tableView.deleteSections([indexPath.section], with: .fade)
            }
            
        }
    }
}

extension SQLiteViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = searchTextField.text {
            presenter.searchItems(with: text)
        }
        searchTextField.resignFirstResponder()
        return true
    }
}

extension SQLiteViewController: SQLitePresenterDelegate {
    
    func updateViews() {
        tableView.reloadData()
        addTextField.text = ""
        searchTextField.text = ""
    }
    
}

