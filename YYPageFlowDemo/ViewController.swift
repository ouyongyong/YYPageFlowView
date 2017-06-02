//
//  ViewController.swift
//  YYPageFlowDemo
//
//  Created by ouyongyong on 2017/6/1.
//  Copyright © 2017年 kila. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = YYPageFlowViewController()
        vc.detailVC = testDetailVC()
        self.navigationController?.pushViewController(vc, animated: true)
//        self.present(vc, animated: true, completion: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class testDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        let table = UITableView(frame: self.view.bounds)
        table.frame.size.width -= 34
        self.view.addSubview(table)
        table.delegate = self
        table.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell?.backgroundView = nil
        }
        
        cell?.textLabel?.text = "\(indexPath.row)"
        cell?.contentView.backgroundColor = UIColor.lightGray
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}

