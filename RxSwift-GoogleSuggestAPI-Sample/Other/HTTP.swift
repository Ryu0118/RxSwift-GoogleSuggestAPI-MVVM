//
//  HTTP.swift
//  RxSwift-GoogleSuggestAPI-Sample
//
//  Created by Ryu on 2022/03/12.
//

import RxSwift
import RxCocoa
import Kanna

class HTTP {
    
    static func get(url: URL) -> Observable<String> {
        
        return Observable<String>.create { observer in
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error { observer.onError(error) }
                else{
                    observer.onNext(String(data: data!, encoding: .utf8)!)
                    observer.onCompleted()
                }
            }
            task.resume()
            
            return Disposables.create()
        }
        
    }
    
}

class API {
    
    static let apiURL = "https://www.google.com/complete/search?hl=en&q="
    
    static func getSuggestions(searchString:String) -> Observable<[Suggestion]> {
        
        return HTTP.get(url: URL(string: API.apiURL + searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! + "&output=toolbar")!)
            .flatMap { response -> Observable<[Suggestion]> in
                
                let doc = try! XML(xml: response, encoding: .utf8)
                
                let suggestions = doc.xpath("//suggestion").reduce([Suggestion]()) { partial, element in
                    if let suggest = element["data"] {
                        return partial + [Suggestion(suggest: suggest)]
                    }else{
                        return partial
                    }
                }

                return Observable.just(suggestions)
            }
        
    }
    
}

