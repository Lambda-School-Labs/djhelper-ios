//
//  GuestLoginViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/16/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import CoreData

class GuestLoginViewController: ShiftableViewController {

    var eventID: Int32? {
        didSet {
            loadViewIfNeeded()
            updateView()
        }
    }
    var currentHost: Host?
    var allHosts: [Host]?
    var allEvents: [Event]?
    var event: Event?
    var isGuest: Bool?
    var eventController: EventController?
    var hostController: HostController?
    var customAlert = CustomAlert()

    // MARK: - Outlets
    @IBOutlet weak var eventCodeTextField: UITextField!
    @IBOutlet weak var viewEventButton: UIButton!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hostController?.fetchAllHostsFromServer(completion: { (results) in
            switch results {
            case let .success(hosts):
                DispatchQueue.main.async {
                    self.allHosts = hosts
                }
            case let .failure(error):
                print("Error fetching all hosts from server: \(error)")
            }
        })

        eventController?.fetchAllEventsFromServer(completion: { (results) in
            switch results {
            case let .success(events):
                DispatchQueue.main.async {
                    self.allEvents = events
                }
            case let .failure(error):
                print("Error fetching all events from server: \(error)")
            }
        })

        setupButtons()
        setUpSubviews()
        eventCodeTextField.delegate = self

        let tapToDismiss = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapToDismiss)
    }

    // I added the network calls to a viewWillAppear override in order to be called
    // after the scene delegate navigates to this scene. When they are only in the
    // viewDidLoad, they are called before the scene delegate navigates here.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hostController?.fetchAllHostsFromServer(completion: { (results) in
            switch results {
            case let .success(hosts):
                DispatchQueue.main.async {
                    self.allHosts = hosts
                }
            case let .failure(error):
                print("Error fetching all hosts from server: \(error)")
            }
        })

        eventController?.fetchAllEventsFromServer(completion: { (results) in
            switch results {
            case let .success(events):
                DispatchQueue.main.async {
                    self.allEvents = events
                }
            case let .failure(error):
                print("Error fetching all events from server: \(error)")
            }
        })
    }

    private func updateView() {
        guard let eventID = eventID else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }
        eventCodeTextField.text = "\(eventID)"
        eventCodeTextField.textColor = .black
        self.view.backgroundColor = .cyan

    }

    // MARK: - Actions

    // perform fetchAllEvents and do a filter for the
    // event number in the text field
    // if present, make that event the current event
    // and make the associated host the current host
    // and set a boolean "guest" property to true
    // if not present, present an error alert

    @IBAction func viewEvents(_ sender: UIButton) {
        print("view event button pressed.")
        guard let eventCode = eventCodeTextField.text,
            !eventCode.isEmpty,
        let allEvents = allEvents,
        let allHosts = allHosts else { return }

        // Check that the text entered is convertible to Int
        guard let intEventCode = Int(eventCode) else {
            let inputAlert = CustomAlert()
            inputAlert.showAlert(with: "Invalid Entry",
                                 message: "The event code must be a whole number only. Please check the input and try again.",
                                 on: self)
            return
        }

        let matchingEventIDs = allEvents.filter { $0.eventID == intEventCode }
        if let matchingEvent = matchingEventIDs.first {
            self.event = matchingEvent
            let matchingHostID = matchingEvent.hostID
            let matchingHosts = allHosts.filter { $0.identifier == matchingHostID }
            if let matchingHost = matchingHosts.first {
                self.currentHost = matchingHost
                self.event?.host = matchingHost
            }
            self.isGuest = true

            // Perform segue to eventPlaylistViewController
            performSegue(withIdentifier: "EventPlaylistSegue", sender: self)

        } else {
//            let unmatchedEventAlert = CustomAlert()
                                    customAlert.showAlert(with: "Event Not Found",
                                                                  message: "There was no event found with the code. Please verify the code and try again.",
                                                                  on: self)
        }
    }

    @objc func dismissAlert() {
        customAlert.dismissAlert()
    }

    // MARK: - Methods
    private func setupButtons() {
        viewEventButton.colorTheme()
    }

    // Programmatically setting up the Sign In button in the view.
    func setUpSubviews() {
        let backToSignIn = UIButton(type: .system)
        backToSignIn.translatesAutoresizingMaskIntoConstraints = false
        backToSignIn.setTitle("Sign In", for: .normal)
        backToSignIn.addTarget(self, action: #selector(self.backToSignIn), for: .touchUpInside)

        let customButtonTitle = NSMutableAttributedString(string: "Sign In", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!,
            NSAttributedString.Key.foregroundColor: UIColor(named: "customTextColor")
        ])

        backToSignIn.setAttributedTitle(customButtonTitle, for: .normal)

        view.addSubview(backToSignIn)

        backToSignIn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        backToSignIn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    }

    @objc private func backToSignIn() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventPlaylistSegue" {
            guard let eventPlaylistVC = segue.destination as? EventPlaylistViewController else { fatalError() }
            eventPlaylistVC.currentHost = currentHost
            eventPlaylistVC.event = event
            eventPlaylistVC.hostController = hostController
            eventPlaylistVC.eventController = eventController
            eventPlaylistVC.isGuest = true
        } else {
            return
        }
    }
}

// Extensions
extension GuestLoginViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
