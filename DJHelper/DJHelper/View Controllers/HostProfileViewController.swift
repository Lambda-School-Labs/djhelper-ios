//
//  HostProfileViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/8/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class HostProfileViewController: ShiftableViewController {

    // MARK: - Properties
    var currentHost: Host? {
        didSet {
            updateViews()
        }
    }
    var hostController: HostController?
    var isGuest: Bool = false

    // MARK: - Outlets
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var websiteTextField: UITextField!
    @IBOutlet var profilePicTextField: UITextField!
    @IBOutlet var bioTextView: UITextView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet weak var pageTitle: UINavigationItem!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePicTextField.delegate = self
        bioTextView.delegate = self
        updateViews()
    }

    // MARK: - Actions
    @IBAction func saveChanges(_ sender: UIBarButtonItem) {

        guard let host = currentHost,
         let hostController = hostController else { return }

        host.username = usernameTextField.text
        host.name = nameTextField.text
        host.email = emailTextField.text
        host.phone = phoneTextField.text
        if let websiteURLString = websiteTextField.text {
            host.website = URL(string: websiteURLString)
        }
        if let profilePicURLString = profilePicTextField.text {
            host.profilePic = URL(string: profilePicURLString)
        }
        host.bio = bioTextView.text

        hostController.updateHost(with: host) { (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Profile Updated",
                                                            message: "Nice! Your profile has been updated!",
                        preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
                        self.tabBarController?.selectedIndex = 0
                    }
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Update Error",
                                                            message:
                        """
                        There was an error updating your profile, with message: \(error). Please verify and try again.
                        """,
                        preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true)
                }
                return
            }
        }
        // successful result should present alert controller
        // failed result should also present alert controller
    }

    // MARK: - Private Methods
    private func updateViews() {
        guard let host = currentHost else { return }
        guard isViewLoaded else { return }

        usernameTextField.text = host.username
        nameTextField.text = host.name
        emailTextField.text = host.email
        phoneTextField.text = host.phone
        websiteTextField.text = host.website?.absoluteString
        profilePicTextField.text = host.profilePic?.absoluteString
        bioTextView.text = host.bio

        if isGuest {
            saveButton.tintColor = UIColor.clear
            pageTitle.title = "\(currentHost?.name ?? "DJ")'s Profile"
        } else {
            pageTitle.title = "Update Profile"
        }
    }
}
