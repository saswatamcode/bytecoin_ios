//
//  CoinManager.swift
//  ByteCoin
//

import Foundation

protocol CoinManagerDelegate {
    func didFailWithError(error: Error)
    func didUpdatePrice(price: String, currency: String)
}

struct CoinManager {
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var delegate: CoinManagerDelegate?
    func getCoinPrice(for currency: String){
        let urlString = "\(baseURL)\(currency)"
        performRequest(with: urlString, currency: currency)
    }
    
    func performRequest(with urlString: String, currency: String){
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                   if let bitcoinPrice = self.parseJSON(safeData) {
                       let priceString = String(format: "%.2f", bitcoinPrice)
                       self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                   }

                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.last
            return lastPrice
        } catch{
            delegate?.didFailWithError(error: error)
          return nil
        }
    }
    
    
}
