/*
See LICENSE folder for this sample’s licensing information.

Abstract:
UICollectionViewCell subclasses to use in TripDetailViewController
*/

import UIKit
import MapKit

class TripDetailCollectionCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    fileprivate func configure() {
    }
}
class TripImageDetailCell: TripDetailCollectionCell {

    static let reuseIdentifier = "imageDetailCollectionCell"
    let imageView = UIImageView()

    override func configure() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}

class TripInformationCell: TripDetailCollectionCell {
    static let reuseIdentifier = "informationCollectionCell"
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let notesLabel = UILabel()
    let categoryImageView = UIImageView()

    override func configure() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(notesLabel)
        contentView.addSubview(categoryImageView)
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = -1
        dateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.textColor = .secondaryLabel
        notesLabel.font = UIFont.preferredFont(forTextStyle: .body)
        dateLabel.adjustsFontForContentSizeCategory = true
        notesLabel.textColor = .secondaryLabel
        notesLabel.numberOfLines = -1
        categoryImageView.tintColor = .secondaryLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            categoryImageView.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 8),
            categoryImageView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            categoryImageView.widthAnchor.constraint(equalToConstant: 16),
            categoryImageView.heightAnchor.constraint(equalToConstant: 16),
            notesLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            notesLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            notesLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            notesLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}

class TripLocationCell: TripDetailCollectionCell {
    let mapView = MKMapView()

    override func configure() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mapView)
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.layer.cornerRadius = 4.0
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
}
