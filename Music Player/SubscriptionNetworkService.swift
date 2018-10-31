//
//  SubscriptionNetworkService.swift
//  Music Player
//
//  Created by Даниил on 13.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

private let itcAccountSecret = "82969ff46d4343c4974ed1f724749d1c"

enum Result<T> {
    case failure(SubscriptionServiceError)
    case success(T)
}

typealias UploadReceiptCompletion = (_ result: Result<Session>) -> Void
typealias SessionId = String

enum SubscriptionServiceError {
    case internalError
    case missingAccountSecret
    case invalidSession
    case noActiveSubscription
    case other(Error)
}

class SubscriptionNetworkService {
    
    private var url = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
    public static let shared = SubscriptionNetworkService()
    let simulatedStartDate: Date
    
    private var sessions = [SessionId: Session]()
    
    init() {
        let persistedDateKey = "SimulatedStartDate"
        if let persistedDate = UserDefaults.standard.object(forKey: persistedDateKey) as? Date {
            simulatedStartDate = persistedDate
        } else {
            let date = Date().addingTimeInterval(-30) // 30 second difference to account for server/client drift.
            UserDefaults.standard.set(date, forKey: "SimulatedStartDate")
            
            simulatedStartDate = date
        }
    }
    
    private func reuploadAfterWrongEnviroment(status: Int) {
        
        if status == 21007 {
            url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        } else {
            return
        }
        SubscriptionService.shared.uploadReceipt()
    }
    
    public func upload(receipt data: Data, completion: @escaping UploadReceiptCompletion) {
        let body = [
            "receipt-data": data.base64EncodedString(),
            "password": itcAccountSecret
        ]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        let url = self.url
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let error = error {
                completion(.failure(.other(error)))
            } else if let responseData = responseData {
                let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
                let session = Session(receiptData: data, parsedReceipt: json)
                self.sessions[session.id] = session
                
                if let status = json["status"] as? Int {
                    if status == 21007 {
                        self.url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
                        SubscriptionService.shared.uploadReceipt()
                    }
                    if status == 0 {
                        completion(.success(session))
                    }
                }
            }
        }
        task.resume()
    }
}
