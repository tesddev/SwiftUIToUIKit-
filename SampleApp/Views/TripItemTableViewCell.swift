/*
See LICENSE folder for this sample’s licensing information.

Abstract:
 UITableViewCell subclasses to use in TripDetailViewController
*/

import UIKit

class TripItemTableViewCell: UITableViewCell {

    var actionHandler: () -> Void = {}
    static let defaultIdentifier = "defaultCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func configure() {
    }

    func onAction(handler: @escaping (() -> Void)) {
        actionHandler = handler
    }
}

class TextFieldCell: TripItemTableViewCell, UITextFieldDelegate {

    static let reuseIdentifier = "textfieldCell"
    let textField = UITextField()
    var textFieldValueChangeHandler: ((UITextField) -> Void) = { _ in }

    override func configure() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        textField.delegate = self
        NSLayoutConstraint.activate([
        textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
        textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        textField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
        textField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    func onTextChange(handler: @escaping ((UITextField) -> Void)) {
        textFieldValueChangeHandler = handler
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        textFieldValueChangeHandler(textField)
    }
}

class DatePickerCell: TripItemTableViewCell {

    static let reuseIdentifier = "datePickerCell"
    let datePicker = UIDatePicker()
    var onDateChangeHandler: ((UIDatePicker) -> Void) = { _ in }

    override func configure() {
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(datePicker)
        datePicker.addTarget(self, action: #selector(changeDate), for: .valueChanged)
        NSLayoutConstraint.activate([
            datePicker.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            datePicker.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor)
        ])
    }

    @objc func changeDate(sender: UIDatePicker) {
        onDateChangeHandler(sender)
    }

    func onDateChange(handler: @escaping ((UIDatePicker) -> Void)) {
        onDateChangeHandler = handler
    }
}

class LocationCell: TripItemTableViewCell {
    static let reuseIdentifier = "locationPickerCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure() {
    }
}

class AddImageButtonCell: TripItemTableViewCell {
    static let reuseIdentifier = "addImageButtonCell"
    let button = UIButton()

    override func configure() {
        button.setTitleColor(UIColor.systemOrange, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(buttonTapAction), for: .touchUpInside)

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            button.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    @objc func buttonTapAction(sender: UIButton) {
        actionHandler()
    }
}

class ImageDisplayCell: TripItemTableViewCell {
    static let reuseIdentifier = "imageDisplayCell"
    let deleteButton = UIButton()
    var deletePhotoHandler: (() -> Void) = {}

    override func configure() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deleteButton)
        let mediumConfiguration = UIImage.SymbolConfiguration(textStyle: .title2)
        var deleteImage = UIImage(systemName: "minus.circle.fill", withConfiguration: mediumConfiguration)
        deleteImage = deleteImage?.withTintColor(.red, renderingMode: .alwaysOriginal)
        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)

        NSLayoutConstraint.activate([
            deleteButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            deleteButton.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
        imageView?.layer.cornerRadius = 6
        imageView?.layer.masksToBounds = true
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        if let imageView {
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 30.0),
                imageView.leadingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: 10),
                imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
            ])
        }
    }

    @objc func deletePhoto(sender: UIButton) {
        deletePhotoHandler()
    }

    func onDelete(handler: @escaping (() -> Void)) {
        deletePhotoHandler = handler
    }
}
