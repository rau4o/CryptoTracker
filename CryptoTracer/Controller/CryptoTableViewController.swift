//
//  CryptoTableViewController.swift
//  CryptoTracer
//
//  Created by rau4o on 11/15/19.
//  Copyright © 2019 rau4o. All rights reserved.
//

import UIKit

class CryptoTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoinData.shared.coins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let coin = CoinData.shared.coins[indexPath.row]
        cell.textLabel?.text = coin.symbol
        cell.imageView?.image = coin.image
        
        return cell
    }
}
