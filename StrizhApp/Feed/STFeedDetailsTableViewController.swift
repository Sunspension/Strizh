//
//  STFeedDetailsTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 10/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage
import GoogleMaps

class STFeedDetailsTableViewController: UIViewController {

    
    private let dataSource = TableViewDataSource()
    
    private var imageDataSource: GenericCollectionViewDataSource<STPostDetailsPhotoCell, STImage>?
    
    private let tableSection = CollectionSection()
    
    private let collectionSection = GenericCollectionSection<STImage>()
    
    private var coordinateBounds = GMSCoordinateBounds()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var actionWrite: UIButton!
    
    
    var user: STUser?
    
    var post: STPost?
    
    var images: [STImage]?
    
    var files: [STFile]?
    
    var locations: [STLocation]?
    
    
    deinit {
        
        print("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        
        self.tableView.dataSource = self.dataSource
        
        self.tableView.register(cell: STPostDetailsMainInfoCell.self)
        self.tableView.register(cell: STPostDetailsMapsCell.self)
        self.tableView.register(cell: STPostDetailsCollectionViewCell.self)
        self.tableView.register(cell: STPostDetailsFileCell.self)
        
        self.navigationItem.title = "Информация"
    
        self.dataSource.sections.append(self.tableSection)
        
        self.createDataSource()
    }

    private func createDataSource() {
        
        self.tableSection.addItem(cellClass: STPostDetailsMainInfoCell.self,
                             item: self.post) { [unowned self] (cell, item) in
                                
                                cell.selectionStyle = .none
                                
                                let viewCell = cell as! STPostDetailsMainInfoCell
                                
                                if let post = item.item as? STPost {
                                    
                                    viewCell.postTitle.text = post.title
                                    viewCell.postDetails.text = post.postDescription
                                    viewCell.favorite.isSelected = post.isFavorite
                                    viewCell.postType.isSelected = post.type == 2 ? true : false
                                    viewCell.postTime.text = post.createdAt?.elapsedInterval()
                                    
                                    if let user = self.user {
                                        
                                        viewCell.userName.text = user.lastName + " " + user.firstName
                                        
                                        guard !user.imageUrl.isEmpty else {
                                            
                                            return
                                        }
                                        
                                        let width = Int(viewCell.userIcon.bounds.size.width * UIScreen.main.scale)
                                        let height = Int(viewCell.userIcon.bounds.size.height * UIScreen.main.scale)
                                        
                                        let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                                        
                                        let urlString = user.imageUrl + queryResize
                                        
                                        let filter = RoundedCornersFilter(radius: viewCell.userIcon.bounds.size.width)
                                        viewCell.userIcon.af_setImage(withURL: URL(string: urlString)!,
                                                                  filter: filter,
                                                                  completion: nil)
                                    }
                                }
        }
        
        if let locations = self.locations, locations.count > 0 {
            
            self.tableSection.addItem(cellClass: STPostDetailsMapsCell.self,
                                 item: locations,
                                 bindingAction: { [unowned self] (cell, item) in
                                    
                                    let locations = item.item as! [STLocation]
                                    let viewCell = cell as! STPostDetailsMapsCell
                                    viewCell.isUserInteractionEnabled = false
                                    viewCell.selectionStyle = .none
                                    
                                    locations.forEach({ location in
                                        
                                        let marker = GMSMarker()
                                        marker.icon = UIImage(named: "icon-pin")
                                        marker.position = CLLocation(latitude: location.lat, longitude: location.lon).coordinate
                                        marker.map = viewCell.mapView
                                        self.coordinateBounds = self.coordinateBounds.includingCoordinate(marker.position)
                                        
                                        if locations.count == 1 {
                                            
                                            viewCell.mapView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 15)
                                        }
                                    })
                                    
                                    if locations.count > 1 {
                                        
                                        viewCell.mapView.animate(with: GMSCameraUpdate.fit(self.coordinateBounds, withPadding: 30))
                                    }
            })
        }
        
        if let images = self.images, images.count > 0 {
            
            // collection view data source
            self.imageDataSource = GenericCollectionViewDataSource(cellClass: STPostDetailsPhotoCell.self, binding: { (cell, item) in
                
                cell.busy.stopAnimating()
                
                let width = Int(cell.image.bounds.size.width * UIScreen.main.scale)
                let height = Int(cell.image.bounds.size.height * UIScreen.main.scale)
                
                let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                
                let url = URL(string: item.item.url + queryResize)!
                
                cell.image.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3),
                                       runImageTransitionIfCached: true, completion: { [weak cell] image in
                                        
                                        cell?.busy.stopAnimating()
                })
            })
            
            self.imageDataSource?.sections.append(self.collectionSection)
            
            images.forEach({ image in
                
                self.collectionSection.add(item: image)
            })
            
            tableSection.addItem(cellClass: STPostDetailsCollectionViewCell.self,
                            item: self.imageDataSource,
                            bindingAction: { (cell, item) in
            
                                let viewCell = cell as! STPostDetailsCollectionViewCell
                                viewCell.selectionStyle = .none
                                let dataSource = item.item as! GenericCollectionViewDataSource<STPostDetailsPhotoCell, STImage>
                                
                                viewCell.collectionView.dataSource = dataSource
                                viewCell.collectionView.delegate = dataSource
                                viewCell.collectionView.reloadData()
            })
        }
        
        if let files = self.files {
            
            files.forEach({ file in
                
                tableSection.addItem(cellClass: STPostDetailsFileCell.self,
                                     item: file,
                                     bindingAction: { (cell, item) in
                                        
                                        let viewCell = cell as! STPostDetailsFileCell
                                        viewCell.selectionStyle = .none
                                        
                                        let file = item.item as! STFile
                                        
                                        viewCell.title.setTitle(file.title, for: .normal)
                })
            })
        }
    }
}
