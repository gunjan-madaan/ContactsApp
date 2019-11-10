//
//  ContactDetailsViewController.swift
//  Contacts
//
//  Created by admin on 02/02/19.
//  Copyright © 2019 GoJek. All rights reserved.
//

import UIKit

class ContactDetailsViewController: UIViewController {

    var contactURL: String?
    var editContact: Contact?

    @IBOutlet weak var contactPhotoView: UIImageView!
    @IBOutlet weak var contactName: UILabel!

    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    @IBOutlet weak var favouriteButtonImageView: UIImageView!

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    @IBAction func favouriteButtonTapped(_ sender: Any) {

        loaderView.startAnimating()

        let isContactFavourted: Bool = editContact?.favorite ?? true
        let isContactFavouretdInvert = !isContactFavourted
        if isContactFavouretdInvert {
            favouriteButtonImageView.image = UIImage.init(named: "favourite_button_selected")
        } else {
            favouriteButtonImageView.image = UIImage.init(named: "favourite_button")
        }
        let contactId = editContact?.id ?? 0
        let url = "http://gojek-contacts-app.herokuapp.com/contacts/\(contactId).json"

        var request = URLRequest(url: URL.init(string: url)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"

        request.httpBody = try! JSONSerialization.data(withJSONObject: ["favorite": isContactFavouretdInvert, "id": contactId], options: [])

        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) -> Void in

            self?.fetchContactDetails()
        }

        task.resume()



    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchContactDetails()
    }

    func fetchContactDetails() {
        let url = URL.init(string: contactURL!)!

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let _ = response as? HTTPURLResponse,
                let urlData = data, error == nil else {
                    return
            }
            let decoder = JSONDecoder.init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            self?.editContact =  try! decoder.decode(Contact.self, from: urlData)

            DispatchQueue.main.async {
                self?.reloadData()
            }
        }
        task.resume()
    }

    func reloadData() {
        loaderView.stopAnimating()

        let fullName = editContact?.fullName
        contactName.text = fullName

        let isContactFavourted: Bool = editContact?.favorite ?? true

        if isContactFavourted {
            favouriteButtonImageView.image = UIImage.init(named: "favourite_button_selected")
        } else {
            favouriteButtonImageView.image = UIImage.init(named: "favourite_button")
        }

        phoneNumberLabel.text = editContact?.phoneNumber ?? ""
        emailLabel.text = editContact?.email ?? ""

        guard let url = URL.init(string: editContact?.profilePic as! String) else {
            contactPhotoView.image = UIImage.init(named: "placeholder_photo")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let _ = response as? HTTPURLResponse,
                let urlData = data, error == nil else {
                    DispatchQueue.main.async {
                        self?.contactPhotoView.image = UIImage.init(named: "placeholder_photo")
                    }
                    return
            }
            let image = UIImage.init(data: urlData)
            DispatchQueue.main.async {
                self?.contactPhotoView.image = image
            }
        }
        task.resume()


    }

}
