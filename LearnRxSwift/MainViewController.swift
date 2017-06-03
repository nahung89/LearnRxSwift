//
//  MainViewController.swift
//  LearnRxSwift
//
//  Created by NAH on 5/13/17.
//  Copyright © 2017 NAH. All rights reserved.
//

import Foundation
import UIKit

enum Example: String {
    case search,
    trait,
    mergezip,
    debouncethrottle,
    operation,
    scheduler,
    flatmap,
    event,
    picker,
    circle,
    sumup
}

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let examples: [Example] = [.search,
                               .trait,
                               .mergezip,
                               .debouncethrottle,
                               .operation,
                               .scheduler,
                               .flatmap,
                               .event,
                               .picker,
                               .circle,
                               .sumup]
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell.textLabel?.text = examples[indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = examples[indexPath.row]
        performSegue(withIdentifier: example.rawValue, sender: example.rawValue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        destination.navigationItem.title = "\(String(describing: sender))"
    }
}
