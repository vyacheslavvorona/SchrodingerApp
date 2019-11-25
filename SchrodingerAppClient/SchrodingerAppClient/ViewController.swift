//
//  ViewController.swift
//  SchrodingerAppClient
//
//  Created by vorona.vyacheslav on 2019/11/25.
//  Copyright © 2019 vorona.vyacheslav. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var cats: [Cat] = []
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var breedTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    private func post(_ cat: Cat) {
        let jsonData = try? JSONSerialization.data(withJSONObject: cat.json)
        var request = URLRequest(url: URL(string: "http://localhost:8080/api/cat")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        task.resume()
    }
    
    private func getCats() {
        var request = URLRequest(url: URL(string: "http://localhost:8080/api/cat")!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [[String: Any]] {
                self?.cats = []
                for catJson in responseJSON {
                    guard let cat = Cat.make(from: catJson) else { continue }
                    self?.cats.append(cat)
                    
                    DispatchQueue.main.sync { [weak self] in
                        self?.tableView.reloadData()
                    }
                }
            }
        }
        task.resume()
    }
    
    private func makeCat() -> Cat? {
        guard let name = nameTextField.text, !name.isEmpty else { return nil }
        guard let age = Int(ageTextField.text ?? "") else { return nil }
        guard let breed = Breed(rawValue: breedTextField.text ?? "") else { return nil }
        return Cat(name: name, age: age, breed: breed)
    }
    
    @IBAction func getCatsTap(_ sender: Any) {
        getCats()
    }
    
    @IBAction func postCatTap(_ sender: Any) {
        guard let cat = makeCat() else {
            let alert = UIAlertController(title: "Error", message: "Invalid data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default))
            self.present(alert, animated: true)
            return
        }
        nameTextField.text = ""
        ageTextField.text = ""
        breedTextField.text = ""
        post(cat)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TableViewCell.self)) as? TableViewCell else {
            fatalError()
        }
        
        let cat = cats[indexPath.row]
        var dataString = "\(cat.name), \(cat.age) years"
        if let breed = cat.breed {
            dataString += ", \(breed.rawValue)"
        }
        cell.catDataLabel.text = dataString
        
        return cell
    }
}

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var catDataLabel: UILabel!
}
