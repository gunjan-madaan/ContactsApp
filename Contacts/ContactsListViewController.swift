//
//  ViewController.swift
//  Contacts
//
//  Created by admin on 29/01/19.
//  Copyright © 2019 GoJek. All rights reserved.
//

import UIKit

struct ContactListSection {
    let sectionTitle: String
    let contacts: [Contact]
}

class ContactsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var contactsListTableView: UITableView!

    var contactListSections: [ContactListSection] = []

    var selectedContactURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contacts"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


        let url = URL.init(string: "https://gojek-contacts-app.herokuapp.com/contacts.json")!

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let responseData = data, error == nil else {
                    return
            }

            let decoder = JSONDecoder.init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {

                let contacts =  try decoder.decode([Contact].self, from: responseData)


                let sortedContacts = contacts.sorted(by: { $0.fullName < $1.fullName })

                self?.contactListSections = []

                let sectionTitles = UILocalizedIndexedCollation.current().sectionTitles

                var calicutaingSections: [ContactListSection] = []


                for title in sectionTitles {
                    let contacts = sortedContacts.filter({ $0.fullName.capitalized.hasPrefix(title)})
                    let section = ContactListSection.init(sectionTitle: title, contacts: contacts)
                    calicutaingSections.append(section)
                }
                self?.contactListSections = calicutaingSections

                DispatchQueue.main.async {
                    self?.contactsListTableView.reloadData()
                }

            } catch {

            }
        }
        task.resume()
    }

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewContact", let destination = segue.destination as? ContactDetailsViewController {
            destination.contactURL = selectedContactURL
        }
    }
}

class ContactCell: UITableViewCell {

    @IBOutlet weak var contactPhotoView: UIImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactFavouriteImageView: UIImageView!

    override func layoutSubviews() {
        super.layoutSubviews()
        contactPhotoView.layer.cornerRadius = contactPhotoView.frame.size.height/2
        contactPhotoView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contactPhotoView.image = nil
        contactNameLabel.text = ""
        contactFavouriteImageView.image = nil
    }
}

struct Contact: Decodable {
    let id: Int?
    let firstName: String?
    let lastName: String?
    let profilePic: String?
    let favorite: Bool?
    let url: String?
    let phoneNumber: String?
    let email: String?

    var fullName: String {
        if firstName == nil && lastName == nil {
            return ""
        } else if firstName == nil {
            return lastName ?? ""
        } else if lastName == nil {
            return firstName ?? ""
        } else {
            return (firstName ?? "")  + " " + (lastName ?? "")
        }
    }
}
