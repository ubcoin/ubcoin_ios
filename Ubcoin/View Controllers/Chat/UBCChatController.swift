//
//  UBCChatController.swift
//  Ubcoin
//
//  Created by Alex Ostroushko on 22/01/2019.
//  Copyright © 2019 UBANK. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar


class UBCChatController: UBCMessagesViewController {
    
    private var isAppendHistory = false
    
    private var item: UBCGoodDM?
    private var deal: UBCDealDM?
    
    @objc convenience init(item: UBCGoodDM) {
        self.init()
        
        self.item = item
    }
    
    @objc convenience init(deal: UBCDealDM) {
        self.init()
        
        self.deal = deal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = item {
            self.navigationItem.setTitle(title: item.title ?? UBLocal.shared.localizedString(forKey: "str_chat", value: ""), subtitle: item.seller.name ?? "")
            UBCSocketIOManager.sharedInstance.enterRoom(item: item)
        } else if let deal = deal {
            self.navigationItem.setTitle(title: deal.item.title ?? UBLocal.shared.localizedString(forKey: "str_chat", value: ""), subtitle: deal.item.seller.name ?? "")
            UBCSocketIOManager.sharedInstance.enterRoom(item: deal.item)
        }
        
        
        messagesCollectionView.messageCellDelegate = self
        
        UBCSocketIOManager.sharedInstance.messageListener {[weak self] message in
            guard let sself = self else {
                return
            }
            sself.insertMessage(message)
        }
        
        UBCSocketIOManager.sharedInstance.historyListener {[weak self] messages in
            guard let sself = self else {
                return
            }
            
            sself.setHistory(messages, append: sself.isAppendHistory)
            sself.isAppendHistory = false

        }
    }
    
    
    
    override func loadMoreMessages() {
        
        if let first = messages.first {
            isAppendHistory = true
            UBCSocketIOManager.sharedInstance.updateHistory(from: first.sentDate)
        }
        
        
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
            //            SampleData.shared.getMessages(count: 20) { messages in
            DispatchQueue.main.async {
                //self.messageList.insert(contentsOf: messages, at: 0)
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.refreshControl.endRefreshing()
            }
            //            }
        }
    }
    
}


//MARK: - MessageCellDelegate

extension UBCChatController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
}

// MARK: - MessageLabelDelegate

extension UBCChatController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
}
