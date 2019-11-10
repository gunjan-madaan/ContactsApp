//
//  ContactsEngine.swift
//  Contacts
//
//  Created by Gunjan on 10/11/19.
//  Copyright © 2019 GoJek. All rights reserved.
//

import Foundation

class ContactsEngine {
    
    class func getContactsRequest(typeString:String,completionBlock: @escaping([Contact]?,Error?)->Void) -> URLSessionTask {
        
        let url = URL.init(string: "https://gojek-contacts-app.herokuapp.com/contacts.json")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let responseData = data, error == nil else {
                    return
            }
            let decoder = JSONDecoder.init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                
                let contacts =  try decoder.decode([Contact].self, from: responseData)
                completionBlock(contacts,nil)
                
            } catch {
                completionBlock(nil,error)
            }
        }
        task.resume()
        return task
    }
    
}
