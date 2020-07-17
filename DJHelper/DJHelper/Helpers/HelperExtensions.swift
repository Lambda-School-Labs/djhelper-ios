//
//  HelperExtensions.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/2/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

extension Date {
    func stringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm a"
//                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
}

extension Date {
    func jsonStringFromDate() -> String {
        let formatter = DateFormatter()
        //        formatter.dateFormat = "M/d/yyyy h:mm a"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        //        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
}

extension String {
    func dateFromString() -> Date? {
        let formatter = DateFormatter()
//        formatter.dateFormat = "M/d/yyyy h:mm a"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        formatter.dateStyle = .short
        return formatter.date(from: self)
    }
}

extension String {
    func eventDateFromString() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm a"
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: self)
    }
}

extension UIView {
    func shake() {
        UIView.animate(withDuration: 0.3, delay: 0.0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseInOut], animations: {
            self.center.x += 8
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.red.cgColor
        }) { _ in
            self.center.x -= 8
            self.layer.borderWidth = 0
        }
    }
}

extension UIButton {
     func colorTheme() {
        let button = self
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "PurpleColor")
        button.layer.masksToBounds = true
        button.layer.cornerRadius = self.frame.size.height / 2
    }
}

extension UIViewController {

    func alertController(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    func activityIndicator(activityIndicatorView: UIActivityIndicatorView, shouldStart: Bool) {
        activityIndicatorView.center.x = self.view.bounds.width / 2
        activityIndicatorView.center.y = self.view.bounds.height / 2
        self.view.addSubview(activityIndicatorView)
        shouldStart == true ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    }
}

extension EventController {
    func deleteEvent(for event: Event) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(event)
        deleteEventFromServer(event) { (_) in
        }
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error deleting event from Core Data \(error)")
        }
    }

    func deleteEventFromServer(_ event: Event, completion: @escaping (Result<Int, EventErrors>) -> Void) {
        let baseURL = URL(string: "https://dj-helper-be.herokuapp.com/api")!
        guard let bearer = Bearer.shared.token else {
            completion(.failure(.couldNotInitializeAnEvent))
            return
        }
        let requestURL = baseURL.appendingPathComponent("auth")
            .appendingPathComponent("event")
            .appendingPathComponent("\(event.eventID)")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue

        request.setValue("\(bearer)", forHTTPHeaderField: "Authorization")

        self.dataLoader.loadData(from: request) { (possibleData, possibleResponse, possibleError) in
            if let response = possibleResponse as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = possibleError {
                print("""
                    Error: \(error.localizedDescription) on line \(#line)
                    in function: \(#function)\n Technical error: \(error)
                    """)
                DispatchQueue.main.async {
                    completion(.failure(.noEventsInServerOrCoreData))
                }
            }

            guard possibleData != nil else {
                print("Error on line: \(#line) in function: \(#function)")
                completion(.failure(.noDataError))
                return
            }

            DispatchQueue.main.async {
                print("success")
                completion(.success(1))
            }
        }
    }
}
