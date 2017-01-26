//
//  FloorUpdatesTableViewController.swift
//  Starlight
//
//  Created by Mark Murray on 1/7/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class FloorUpdatesTableViewController: JSQMessagesViewController {
    static let navConStoryboardId = "FloorUpdatesNavigationController"

    @IBOutlet var menuBarButton: UIBarButtonItem!
    
    let incomingMessagesBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.gray)!
    let outgoingMessagesBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.menuBarButton.target = self.revealViewController()
            self.menuBarButton.action = Selector(("revealToggle:"))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.showLoadEarlierMessagesHeader = true
        self.senderId = "vox"
        self.senderDisplayName = "populi"

        self.getFloorUpdatesNextPage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadToolbarWithHomeLegislators()
        
        let insets = UIEdgeInsetsMake(0, 0, 4+(self.navigationController?.toolbar.frame.size.height)!, 0)
        self.collectionView.contentInset = insets
        self.collectionView.scrollIndicatorInsets = insets
    }
    
    private func getFloorUpdatesNextPage() {
        DataManager.sharedInstance.getFloorUpdatesNextPage { (indexesResult) in
            switch indexesResult {
            case .error(let error):
                self.showAlertWithTitle(title: "Error!", message: error.localizedDescription)
            case .indexes(let indexes):
                var indexPaths = [IndexPath]()
                
                for i in 0..<indexes.count {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                
                self.collectionView.insertItems(at: indexPaths)
                
                if let lastIndexPath = indexPaths.last {
                    self.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    override func isOutgoingMessage(_ messageItem: JSQMessageData!) -> Bool {
        return messageItem.senderId() == "senate"
    }
    
    //MARK: JSQMessagesCollectionViewDataSource
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let index = DataManager.sharedInstance.floorUpdates.count-1 - indexPath.row
        return DataManager.sharedInstance.floorUpdates[index] as! FloorUpdate;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let floorUpdate = self.collectionView(self.collectionView, messageDataForItemAt: indexPath) as! FloorUpdate
        
        if floorUpdate.chamber == "house" {
            return self.incomingMessagesBubbleImage
        } else {
            return self.outgoingMessagesBubbleImage
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        self.getFloorUpdatesNextPage()
    }
    
    //MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.sharedInstance.floorUpdates.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        // occasionally a cell will get reloaded with black text
        cell.textView.textColor = UIColor.white
        
        return cell
    }

}
