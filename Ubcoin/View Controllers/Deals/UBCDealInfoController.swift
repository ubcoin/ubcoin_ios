//
//  UBCDealInfoController.swift
//  Ubcoin
//
//  Created by Alex Ostroushko on 28/01/2019.
//  Copyright © 2019 UBANK. All rights reserved.
//

import UIKit
import MessageUI

class UBCDealInfoController: UBViewController {

    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var itemIcon: UIImageView!
    @IBOutlet weak var itemTitle: HUBLabel!
    @IBOutlet weak var itemDesc: HUBLabel!
    
    @IBOutlet weak var deliveryView: UBCDeliverySelectionView!
    @IBOutlet weak var buyerDeliveryAddressView: UBCBuyerDeliveryAddressView!
    @IBOutlet weak var buyerDeliveryConfirmView: UBCBuyerDeliveryConfirmedView!
    
    @IBOutlet weak var changeDeliveryView: UBCChangeDeliveryView!
    @IBOutlet weak var currencyConfirmButtonView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusTitle: HUBLabel!
    @IBOutlet weak var statusDesc: HUBLabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var confirmDigitalItemView: UIView!
    @IBOutlet weak var confirmDigitalItemButton: HUBGeneralButton!
    @IBOutlet weak var sellerView: UBCSellerView!
    
    @IBOutlet weak var confirmDeliveryView: UIView!
    @IBOutlet weak var confirmDeliveryButton: HUBGeneralButton!
    
    @IBOutlet weak var sellerDeliveryCostView: UBCSellerDeliveryCostView!
    @IBOutlet weak var sellerFirstDeliveryCostView: UBCSellerFirstDeliveryCostView!
    
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var progressView: StepProgressView!
    
    @IBOutlet weak var paymentContainerView: UIView!
    @IBOutlet weak var itemPrice: HUBLabel!
    
    @IBOutlet weak var actionButton: HUBGeneralButton!
    
    private var dealID: String?
    private var purchaseDM: UBCPurchaseDM?
    private var content = [UBTableViewRowData]()
    
    private var completion: (() -> Void)?
    
    private var isNowBuy:Bool = false {
        didSet {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = !isNowBuy
        }
    }
    
    private var deliveryAddressText = ""
    
    @objc convenience init(item: UBCGoodDM, deal: UBCDealDM, completion: (() -> Void)? = nil) {
        self.init()
        self.completion = completion
        self.purchaseDM =  UBCPurchaseDM(item: item, deal: deal)
    }

    @objc convenience init(item: UBCGoodDM) {
        self.init()
        
        self.purchaseDM = UBCPurchaseDM(item: item)
    }

    @objc convenience init(deal: UBCDealDM, completion: (() -> Void)? = nil) {
        self.init()
        self.completion = completion
        self.purchaseDM = UBCPurchaseDM(deal: deal)
    }

    @objc convenience init?(dealID: String?) {
        
        guard let dealID = dealID else { return nil }
        
        self.init()
        
        self.dealID = dealID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "str_purchase"
        
        setupViews()
        
        if let dealID = dealID {
            startActivityIndicatorImmediately()
            UBCDataProvider.shared.checkStatus(forDeal: dealID) { [weak self] success, deal in
                self?.stopActivityIndicator()
                
                if let deal = deal {
                    self?.purchaseDM = UBCPurchaseDM(deal: deal)
                    self?.setupContent()
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            setupContent()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !isNowBuy
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func updateInfo(withPushParams params: [AnyHashable : Any]!) {
        guard let checkDealId = params["dealId"] as? String, let item = purchaseDM?.item else {
            return
        }
        
        UBCDataProvider.shared.checkStatus(forDeal: checkDealId, withCompletionBlock: { [weak self] success, deal in
            guard let _deal = deal else {
                return
            }
            self?.purchaseDM =  UBCPurchaseDM(item: item, deal: _deal)
            self?.setupContent()

        })
        
    }
    
    override func navigationButtonBackClick(_ sender: Any!) {
        if isNowBuy == true {
            if let tabBarController = navigationController?.viewControllers.first as? UITabBarController,
                let marketController = tabBarController.selectedViewController as? UBCMarketController  {
                marketController.updateInfoIfBuy(self.purchaseDM?.item?.id)
            }
            navigationController?.popToRootViewController(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    private func setupViews() {
        itemIcon.cornerRadius = 5
        sellerView.delegate = self
        
        confirmDigitalItemButton.backgroundColor = UBCColor.green
        confirmDigitalItemButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        confirmDeliveryButton.backgroundColor = UBCColor.green
        confirmDeliveryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        progressView.lineWidth = 2
        progressView.textFont = UBFont.titleFont
        progressView.detailFont = UBFont.descFont
        
        progressView.currentStepColor = UBCColor.green
        progressView.pastStepColor = UBCColor.green
        progressView.futureStepColor = UBColor.titleColor.withAlphaComponent(0.2)

        progressView.currentTextColor = UBColor.navigationTitleColor
        progressView.pastTextColor = UBColor.navigationTitleColor
        progressView.futureTextColor = UBColor.titleColor.withAlphaComponent(0.2)
        progressView.currentDetailColor = UBColor.descColor
    }
    
    private func setupContent() {
        guard let purchaseDM = purchaseDM else { return }
        
        if let item = purchaseDM.item {
            
            //let status = purchaseDM.deal?.id
            
            //MARK: Global Views
            
            let itemIconURL = URL(string: item.imageURL ?? "")
            itemIcon.sd_setImage(with: itemIconURL, placeholderImage: UIImage(named: "item_default_image"), options: [], completed: nil)
            itemTitle.text = item.title
            
            itemDesc.text = purchaseDM.itemDisplayPrice
            itemPrice.text = purchaseDM.itemDisplayPrice
            
            deliveryView.setup(item: item)
            deliveryView.isHidden = item.isDigital || purchaseDM.isPurchase
            
            let person = item.isMyItem ? purchaseDM.deal?.buyer : purchaseDM.seller
            sellerView.setup(seller: person, isSeller: !item.isMyItem)
            
            statusImageView.isHidden = item.isDigital
            
            if item.isDigital {
                
                buyerDeliveryAddressView.isHidden = true
                buyerDeliveryConfirmView.isHidden = true
                currencyConfirmButtonView.isHidden = false
                confirmDeliveryView.isHidden = true
                sellerFirstDeliveryCostView.isHidden = true
                changeDeliveryView.isHidden = true
                sellerDeliveryCostView.isHidden = true
                
            } else {
                
                //MARK: Delivery Views
                
                buyerDeliveryAddressView.isHidden = !deliveryView.isDelivery && !deliveryView.isHidden || purchaseDM.isPurchase
                buyerDeliveryAddressView.deliveryTextView.text = deliveryAddressText
                
                let isDeliveryPriceNeedApproveBuyer = purchaseDM.isPurchase && purchaseDM.deal?.status == DEAL_PRICE_DEFINED && !item.isMyItem
                buyerDeliveryConfirmView.isHidden = !isDeliveryPriceNeedApproveBuyer
                buyerDeliveryConfirmView.setup(purchaseDM.deal)
                
                currencyConfirmButtonView.isHidden = deliveryView.isDelivery && deliveryAddressText == ""
                
                let isPriceConfirmed = purchaseDM.deal?.status == DEAL_PRICE_CONFIRMED && item.isMyItem
                confirmDeliveryView.isHidden = !isPriceConfirmed
                
                let firstSetPriceForDelivery = purchaseDM.isPurchase && purchaseDM.deal?.status == DEAL_STATUS_ACTIVE && item.isMyItem && purchaseDM.deal?.withDelivery == true
                sellerFirstDeliveryCostView.isHidden = !firstSetPriceForDelivery
                sellerFirstDeliveryCostView.setup(purchaseDM.deal)
                
                let showChangeDeliveryMethod = purchaseDM.isPurchase && purchaseDM.deal?.status == DEAL_STATUS_ACTIVE && purchaseDM.deal?.withDelivery == false
                changeDeliveryView.isHidden = !showChangeDeliveryMethod
                changeDeliveryView.setup(purchaseDM.deal, isMyId: item.isMyItem)
                
                let secondSetPriceForDelivery = purchaseDM.isPurchase && purchaseDM.deal?.status == DEAL_PRICE_DEFINED && item.isMyItem
                sellerDeliveryCostView.isHidden =  !secondSetPriceForDelivery
                sellerDeliveryCostView.setupDeal(purchaseDM.deal)
                
            }
            
            //MARK: Confirm button
            
            confirmDigitalItemButton.title = purchaseDM.confirmButtonTitle
            confirmDigitalItemView.isHidden = true
            
            if purchaseDM.isNeedShowForDigitalItem {
                confirmDigitalItemView.isHidden = false
            }
            else if purchaseDM.isNeedShowForMeetingItem {
                confirmDigitalItemView.isHidden = false
            }
            else if purchaseDM.isNeedShowForDeliveryItem {
                confirmDigitalItemView.isHidden = false
            }
        }
        
        //MARK: Status
    
        statusImageView.image = purchaseDM.deliveryImage
        statusTitle.text = purchaseDM.longStatusTitle
        statusTitle.isHidden = statusTitle.text?.isEmpty == true
        statusDesc.text = purchaseDM.longStatusDesc
        statusDesc.isHidden = statusDesc.text?.isEmpty == true
        statusView.isHidden = confirmDigitalItemView.isHidden && statusTitle.isHidden && statusDesc.isHidden
        paymentContainerView.isHidden = purchaseDM.isPurchase
        
        progressContainerView.isHidden = !purchaseDM.isPurchase
        if let deal = purchaseDM.deal, let status = deal.currentStatus {
        
            
            
            progressView.steps = deal.statusDescriptions.map { $0.title }
            var details: [Int: String] = [:]
            for (index, status) in deal.statusDescriptions.enumerated() {
                details[index] = status.desc == "" && index != deal.statusDescriptions.count-1 ? " " : status.desc
            }
            progressView.details = details
            progressView.currentStep = deal.statusDescriptions.index(of: status) ?? 0
        }
        
        
        actionButton.isHidden = !purchaseDM.isPurchase
        actionButton.title = purchaseDM.actionButtonTitle
        
        if purchaseDM.isCanceled {
            actionButton.isHidden = true
        }
        
        
    }
    
    //MARK: - Actions
    
    @IBAction func showItem() {
        if let controller = UBCGoodDetailsController(good: purchaseDM?.item, andDeal: true) {
             self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func confirmDigitalItem() {
        guard let deal = purchaseDM?.deal else { return }
        
        startActivityIndicator()
        UBCDataProvider.shared.confirmDeal(deal.id) { [weak self] success, deal in
            self?.stopActivityIndicator()
            
            if let deal = deal {
                self?.purchaseDM = UBCPurchaseDM(deal: deal)
                self?.setupContent()
                if let _completion = self?.completion {
                    _completion()
                }
            }
        }
    }
    
    @IBAction func confirmDeliveryButtonTouch(_ sender: Any) {
        guard let deal = purchaseDM?.deal else { return }
        startActivityIndicator()
        
        UBCDataProvider.shared.startDelivery(forDeal: deal.id, withCompletionBlock: { [weak self] success, deal in
            self?.stopActivityIndicator()
            
            if let deal = deal {
                self?.purchaseDM = UBCPurchaseDM(deal: deal)
                self?.setupContent()
                if let _completion = self?.completion {
                    _completion()
                }
            }
        })
        
    }
    
    @IBAction func footerAction() {
        guard let purchaseDM = purchaseDM else { return }
        
        if purchaseDM.canCancelDeal {
            guard let deal = purchaseDM.deal else { return }
            
            startActivityIndicator()
            UBCDataProvider.shared.cancelDeal(deal.id) { [weak self] success in
                self?.stopActivityIndicator()
                
                if success {
                    if let _completion = self?.completion {
                        _completion()
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationItemChanged), object: nil)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            sendEmail()
        }
    }
    
    private func confirmPurchase(currency: String) {
        guard let item = purchaseDM?.item else { return }
        
        startActivityIndicator()
        UBCDataProvider.shared.buyItem(item.id,
                                       isDelivery: deliveryView.isDelivery,
                                       currency: currency,
                                       comment: deliveryAddressText) { [weak self] success, deal in
                                        self?.stopActivityIndicator()
                                        
                                        if let deal = deal {
                                            self?.purchaseDM = UBCPurchaseDM(deal: deal)
                                            self?.setupContent()
                                            self?.isNowBuy = true
                                            if let _completion = self?.completion {
                                                _completion()
                                            }
                                        }
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@ubcoin.io"])
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
}

extension UBCDealInfoController: UBCBuyerDeliveryConfirmedDelegate {
    
    func confirmDeliveryPrice(_ dealId: String, _ price: String, _ needTopUpYourBalance: Bool, _ needTopBalanceText: String, _ alertMessageText: String) {
        if needTopUpYourBalance == false {
            UBAlert.show(withTitle: alertMessageText,
                         andMessage: "str_confirm_purchase".localizedString(),
                         titleButtonMain: "str_confirm",
                         titleButtonCancel: "ui_button_cancel") { [weak self] index in
                            if index != CANCEL_INDEX {
                                self?.confirmDeliveryPrice(dealId, price)
                            }
            }
        } else {
            UBAlert.show(withTitle: "str_please_top_up_your_balance", andMessage: needTopBalanceText)
        }
    }
    
    func confirmDeliveryPrice(_ dealId: String, _ price: String) {
        startActivityIndicator()
        UBCDataProvider.shared.confirmDeliveryPrice(forDeal: dealId, price: price, withCompletionBlock: { [weak self] completion, deal in
            self?.stopActivityIndicator()
            
            if let deal = deal {
                self?.purchaseDM = UBCPurchaseDM(deal: deal)
                self?.setupContent()
                if let _completion = self?.completion {
                    _completion()
                }
            }
            
        })
    }
    
}


extension UBCDealInfoController: UBCSellerDeliveryCostViewDelegate {
    
    func confirmNewDeliveryPrice(_ dealId: String, _ price: String) {
        startActivityIndicator()
        
        UBCDataProvider.shared.setDeliveryPriceForDeal(dealId, price: price, withCompletionBlock: { [weak self] completion, deal in
            self?.stopActivityIndicator()
            
            if let deal = deal {
                self?.purchaseDM = UBCPurchaseDM(deal: deal)
                self?.setupContent()
                if let _completion = self?.completion {
                    _completion()
                }
            }
        })
    }
    
    
    
    
}

extension UBCDealInfoController: UBCChangeDeliveryViewDelegate {
    
    func changeDeliveryTouch(_ dealId: String) {
        startActivityIndicator()
        
        UBCDataProvider.shared.changePersonalMeetingToDelivery(forDeal: dealId, withCompletionBlock: {[weak self] completion, deal in
            self?.stopActivityIndicator()
            
            if let deal = deal {
                self?.purchaseDM = UBCPurchaseDM(deal: deal)
                self?.setupContent()
                if let _completion = self?.completion {
                    _completion()
                }
            }
        })
    }
}

extension UBCDealInfoController: UBCSellerViewDelegate {
    
    func show(seller: UBCSellerDM) {
        let controller = UBCSellerController(seller: seller)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func chat(seller: UBCSellerDM) {
        var controller: UBCChatController?
        
        if let item = purchaseDM?.item{
            controller = UBCChatController(item: item)
        }
        
        guard let _controller = controller else {
            return
        }
        
        self.navigationController?.pushViewController(_controller, animated: true)
    }
}

extension UBCDealInfoController: UBCCurrencySelectionViewDelegate {
    
    func confirm(isETH: Bool, currency: String) {
        
        guard let balance = UBCBalanceDM.loadBalance(),
            let item = purchaseDM?.item else { return }
        
        if isETH {
            if balance.amountETH.doubleValue > item.priceInETH.doubleValue {
                let title = item.priceInETH.coinsPriceString + " ETH " + "str_will_be_blocked_on_your_wallet".localizedString()
                UBAlert.show(withTitle: title,
                             andMessage: "str_confirm_purchase".localizedString(),
                             titleButtonMain: "str_confirm",
                             titleButtonCancel: "ui_button_cancel") { index in
                                if index != CANCEL_INDEX {
                                    self.confirmPurchase(currency: currency)
                                }
                }
            } else {
                UBAlert.show(withTitle: "str_please_top_up_your_balance", andMessage: "str_you_don_have_enough_eth_on_your_wallet")
            }
        } else {
            if balance.amountUBC.doubleValue > item.price.doubleValue {
                let title = item.price.priceString + " UBC " + "str_will_be_blocked_on_your_wallet".localizedString()
                UBAlert.show(withTitle: title,
                             andMessage: "str_confirm_purchase".localizedString(),
                             titleButtonMain: "str_confirm",
                             titleButtonCancel: "ui_button_cancel") { index in
                                if index != CANCEL_INDEX {
                                    self.confirmPurchase(currency: currency)
                                }
                }
            } else {
                UBAlert.show(withTitle: "str_please_top_up_your_balance", andMessage: "str_you_don_have_enough_ubc_on_your_wallet")
            }
        }
    }
}

extension UBCDealInfoController: UBCDeliverySelectionViewDelegate {
   
    func showSellerLocation() {
        let controller = UBCMapSelectController(title: "str_seller_location", location: purchaseDM?.item?.location)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func changeDeliveryType(isDelivery: Bool) {
        buyerDeliveryAddressView.isHidden = !isDelivery
        currencyConfirmButtonView.isHidden = isDelivery && deliveryAddressText == ""
    }
}

extension UBCDealInfoController : UBCBuyerDeliveryAddressViewDelegate {
    
    func buyerDeliveryAddress(_ address: String) {
        deliveryAddressText = address
        setupContent()
        
    }
}

extension UBCDealInfoController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
