//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Arda Nar on 15.09.2023.
//

import Foundation

protocol CoinManagerDelegate{
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager{
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AVAX","BNB","BTC","ETH","MANA","SAND","SHIB","SOL","XRP"]
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate"
    let apiKey = "D3ED8437-EA3C-4659-BA2E-22D1C30858EB"
    
    
    func getCoinPrice(for currency: String){
        let urlString = "\(baseURL)/\(currency)/USD?apikey=\(apiKey)"
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let bitcoinPrice = parseJson(safeData){
                        let priceString = String(format: "%03f", bitcoinPrice)
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func parseJson(_ data: Data) -> Double?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
