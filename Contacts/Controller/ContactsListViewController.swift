//
//  ViewController.swift
//  Contacts
//
//  Created by admin on 29/01/19.
//  Copyright © 2019 GoJek. All rights reserved.
//

import UIKit

class ContactsListViewController: UIViewController {

    // MARK:- IBOutlets
    @IBOutlet weak var contactsListTableView: UITableView!

    // MARK:- Variables
    var contactListSections: [ContactListSection] = []
    var selectedContactURL: String?

    // MARK:- LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contacts"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getContactsFromApi(typedString: "abc")
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewContact", let destination = segue.destination as? ContactDetailsViewController {
            destination.contactURL = selectedContactURL
        }
    }
    
    //MARK:- API HIT
    func getContactsFromApi(typedString : String) {
        
        ContactsEngine.getContactsRequest(typeString: typedString) { (contacts, error) in
            guard let contacts = contacts else {
                print(error?.localizedDescription ?? "Error")
                return
            }
            let sortedContacts = contacts.sorted(by: { $0.fullName < $1.fullName })
            self.contactListSections = []
            let sectionTitles = UILocalizedIndexedCollation.current().sectionTitles
            var calicutaingSections: [ContactListSection] = []
            for title in sectionTitles {
                let contacts = sortedContacts.filter({ $0.fullName.capitalized.hasPrefix(title)})
                let section = ContactListSection.init(sectionTitle: title, contacts: contacts)
                calicutaingSections.append(section)
            }
            self.contactListSections = calicutaingSections
            DispatchQueue.main.async {
                self.contactsListTableView.reloadData()
            }
        }
        
    }
}

extension ContactsListViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactListSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactListSections[section].contacts.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if contactListSections[section].contacts.count == 0 {
            return nil
        }
        return contactListSections[section].sectionTitle
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactListSections.compactMap({ $0.sectionTitle })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = contactListSections[indexPath.section].contacts[indexPath.row]
        selectedContactURL = data.url as! String
        performSegue(withIdentifier: "viewContact", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! ContactCell
        let contact = contactListSections[indexPath.section].contacts[indexPath.row]
        cell.contactNameLabel.text = contact.fullName
        cell.contactFavouriteImageView.isHidden = !(contact.favorite ?? false)
        cell.contactPhotoView.image = UIImage.init(named: "placeholder_photo")
        
        guard let profilePic = contact.profilePic, let url = URL.init(string: profilePic) else {
            return cell
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak cell] data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let urlData = data, error == nil else {
                    DispatchQueue.main.async {
                        cell?.contactPhotoView.image = UIImage.init(named: "placeholder_photo")
                    }
                    return
            }
            let image = UIImage.init(data: urlData)
            DispatchQueue.main.async {
                cell?.contactPhotoView.image = image
            }
        }
        task.resume()
        return cell
    }
    
}

