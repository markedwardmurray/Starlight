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
    @IBOutlet var infoBarButton: UIBarButtonItem!
    
    let incomingMessagesBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.gray)!
    let outgoingMessagesBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())!
    
    let houseAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: "HR", backgroundColor: UIColor.gray, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 12), diameter: 34)
    let senateAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: "Sen", backgroundColor: UIColor.jsq_messageBubbleBlue(), textColor: UIColor.white, font: UIFont.systemFont(ofSize: 12), diameter: 34)
    
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

        if DataManager.sharedInstance.floorUpdates.count == 0 {
            self.getFloorUpdatesNextPage()
        } else {
            self.getFloorUpdatesRefresh()
        }
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
    
    private func getFloorUpdatesRefresh() {
        DataManager.sharedInstance.getFloorUpdatesRefresh { (indexesResult) in
            switch indexesResult {
            case .error(let error):
                self.showAlertWithTitle(title: "Error!", message: error.localizedDescription)
            case .indexes(let indexes):
                var indexPaths = [IndexPath]()
                
                for i in 0..<indexes.count {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                
                self.collectionView.insertItems(at: indexPaths)
            }
        }
    }
    
    @IBAction func infoBarButtonTapped(_ sender: UIBarButtonItem) {
        self.showAlertWithTitle(title: "Floor Updates", message: "These are recent real time, to-the-minute updates from the House and Senate floor.\n\nHouse floor updates are in gray and are sourced from the House Clerk.\n\nSenate updates are in blue and are sourced from the Senate Periodical Press Gallery.\n\nPlease note that the Senate does not offer precise timestamps. ")
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
        let floorUpdate = self.collectionView(collectionView, messageDataForItemAt: indexPath) as! FloorUpdate
        
        let isNotLastItem = indexPath.row < self.collectionView(collectionView, numberOfItemsInSection: 0)-1
        if isNotLastItem == true {
            let nextIndexPath = IndexPath(row: indexPath.row+1, section: 0)
            let nextFloorUpdate = self.collectionView(collectionView, messageDataForItemAt: nextIndexPath) as! FloorUpdate
            if floorUpdate.chamber == nextFloorUpdate.chamber {
                return nil
            }
        }
    
        if floorUpdate.chamber == "house" {
            return self.houseAvatar
        } else if floorUpdate.chamber == "senate" {
            return self.senateAvatar
        } else {
            return nil
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let floorUpdate = self.collectionView(collectionView, messageDataForItemAt: indexPath) as! FloorUpdate
        
        return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: floorUpdate.timestamp)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        self.getFloorUpdatesNextPage()
    }
    
    //MARK: JSQCollectionViewFlowLayoutDelegate
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        guard indexPath.row > 0 else {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        let previousIndexPath = IndexPath(row: indexPath.row-1, section:0)
        guard let previousLabelText = self.collectionView(collectionView, attributedTextForCellTopLabelAt: previousIndexPath) else {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        guard let labelText = self.collectionView(collectionView, attributedTextForCellTopLabelAt: indexPath) else {
            return 0
        }
        
        if (previousLabelText.isEqual(to: labelText)) {
            return 0
        } else {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
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
