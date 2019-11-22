//
//  CoinData.swift
//  CryptoTracer
//
//  Created by rau4o on 11/15/19.
//  Copyright © 2019 rau4o. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol CoinDataDelegate: class {
    @objc optional func newPrices()
    @objc optional func newHistory()
}

class CoinData {
    static let shared = CoinData()
    var coins = [Coin]()
    weak var delegate: CoinDataDelegate?
    
    private init() {
        let symbols = ["BTC","ETH","LTC"]
        
        for symbol in symbols {
            let coin = Coin(symbol: symbol)
            coins.append(coin)
        }
    }
    
    func getPrices() {
        var listOfSymbols = ""
        for coin in coins {
            listOfSymbols += coin.symbol
            if coin.symbol != coins.last?.symbol {
                listOfSymbols += ","
            }
        }
        Alamofire.request("https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(listOfSymbols)&tsyms=USD").responseJSON { (response) in
            if let json = response.result.value as? [String:Any] {
                for coin in self.coins {
                    if let coinJson = json[coin.symbol] as? [String:Double] {
                        if let price = coinJson["USD"] {
                            coin.price = price
                        }
                    }
                }
                self.delegate?.newPrices?()
            }
        }
    }
    func doubleToMoneyString(double: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        if let fancyPrice = formatter.string(from: NSNumber(floatLiteral: double)) {
            return fancyPrice
        }
        else {
            return "ERROR"
        }
    }
}

class Coin {
    var symbol = ""
    var image = UIImage()
    var price = 0.0
    var amount = 0.0
    var historicalData = [Double]()
    
    init(symbol: String) {
        self.symbol = symbol
        if let image = UIImage(named: symbol) {
            self.image = image
        }
    }
    
    func getHistoricalData() {
        Alamofire.request("https://min-api.cryptocompare.com/data/histoday?fsym=\(symbol)&tsym=USD&limit=30").responseJSON { (response) in
            if let json = response.result.value as? [String: Any] {
                if let pricesJson = json["Data"] as? [[String: Double]] {
                    self.historicalData = []
                    for priceJson in pricesJson {
                        if let closePrice = priceJson["close"] {
                            print(closePrice)
                            self.historicalData.append(closePrice)
                        }
                    }
                    CoinData.shared.delegate?.newHistory?()
                }
            }
        }
    }
    
    func priceAsString() -> String {
        if price == 0.0 {
            return "Loading..."
        }
//        let formatter = NumberFormatter()
//        formatter.locale = Locale(identifier: "en_US")
//        formatter.numberStyle = .currency
//        if let fancyPrice = formatter.string(from: NSNumber(floatLiteral: price)) {
//            return fancyPrice
//        }
//        else {
//            return "ERROR"
//        }
        
        return CoinData.shared.doubleToMoneyString(double: price)
    }
    
    func amountasString() -> String{
        return CoinData.shared.doubleToMoneyString(double: amount * price)
    }
}
