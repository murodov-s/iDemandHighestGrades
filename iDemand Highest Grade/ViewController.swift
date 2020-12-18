//
//  ViewController.swift
//  iDemand Highest Grade
//
//  Created by Safaralibek Murodov on 12/17/20.
//  Copyright © 2020 Safaralibek Murodov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    private var baseUrl = "https://aucatranslator.azurewebsites.net/api/v1/wordtranslation/?word="
    
    private var wordsData: [String] = []
    private var fullMessage = ""
    
    @IBOutlet weak var wordTextField: UITextField!
    @IBOutlet weak var addWordButton: UIButton!
    @IBOutlet weak var fullMessageButton: UIButton!
    @IBOutlet weak var wordsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        wordTextField.delegate = self
        
        wordsTableView.register(WordsTableViewCell.self, forCellReuseIdentifier: "wordsTableViewCellId")
        wordsTableView.keyboardDismissMode = .interactive
    }
    
    private func translateWord(word: String, index: Int) {
        let url = URL(string: baseUrl + word)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                
                switch httpResponse.statusCode {
                case 200:
                    guard let data = data else { return }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                            if let originalWord = json["originalWord"] {
                                print(originalWord)
                            }
                            if let translation = json["translation"] {
                                print(translation)
                                self.userDefaults.set(translation, forKey: word) // save translation for a word in userDefaults
                                self.fullMessage += "\(translation) " // add translated word into a sentence(full message)
                            }
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                default:
                    print("error")
                }
            }
        }
        
        task.resume()
    }
    
    private func displayAlert(message: String) {
        let alert = UIAlertController(title: "Translation", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addWord(_ sender: Any) {
        if let word = wordTextField.text {
            translateWord(word: word, index: -1)
            wordsData.append(word)
            wordsTableView.reloadData()
        }
    }
    
    @IBAction func showFullMessage(_ sender: Any) {
        displayAlert(message: fullMessage)
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordsTableViewCellId") as! WordsTableViewCell
        cell.textLabel?.text = wordsData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let value = userDefaults.string(forKey: wordsData[indexPath.row]) {
            displayAlert(message: value)
        } else {
            wordsData.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // hide keyboard when pressing return
        self.view.endEditing(true)
        return false
    }
}
