//
//  SearchBarViewModel.swift
//  RxSwift-GoogleSuggestAPI-Sample
//
//  Created by Ryu on 2022/03/12.
//

import RxSwift
import RxRelay
import RxCocoa

protocol SuggestAPIViewModelType: AnyObject {
    var inputs:SuggestAPIViewModelInputs { get }
    var outputs:SuggestAPIViewModelOutputs { get }
}

protocol SuggestAPIViewModelInputs: AnyObject {
    var searchObserver: AnyObserver<String> { get }
}

protocol SuggestAPIViewModelOutputs: AnyObject {
    var suggestionsObserver: Driver<[Suggestion]> { get }
}


final class SuggestAPIViewModel: SuggestAPIViewModelType, SuggestAPIViewModelInputs, SuggestAPIViewModelOutputs {
    var inputs: SuggestAPIViewModelInputs { return self }
    var outputs: SuggestAPIViewModelOutputs { return self }
    
    private let disposeBag = DisposeBag()
    
    //inputs
    private let searchSubject = PublishSubject<String>()
    var searchObserver: AnyObserver<String> {
        return searchSubject.asObserver()
    }
    
    //outputs
    private let suggestionsSubject = PublishSubject<[Suggestion]>()
    var suggestionsObserver: Driver<[Suggestion]> {
        return suggestionsSubject.asDriver(onErrorJustReturn: [])
    }
    
    init() {
        
        searchSubject.asObservable()
            .distinctUntilChanged()
            .do {[weak self] suggestions in
                if suggestions.isEmpty {
                    self?.suggestionsSubject.onNext([])
                }
            }
            .debounce(.nanoseconds(5), scheduler: MainScheduler.instance)
            .flatMapLatest { string -> Observable<[Suggestion]> in
                return API.getSuggestions(searchString: string)
            }
            .subscribe {[weak self] suggestions in
                self?.suggestionsSubject.onNext(suggestions)
            }
            .disposed(by: disposeBag)
        
    }
    
    
}
