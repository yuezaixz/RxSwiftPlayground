//: [Previous](@previous)

import XCPlayground
import UIKit
import RxSwift
import RxCocoa
import SnapKit

let containerView = UIView()
containerView.backgroundColor = .red
containerView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)

let resultLabel = UILabel()
containerView.addSubview(resultLabel)
resultLabel.backgroundColor = .gray
resultLabel.text = "无"
let loadButton = UIButton()
containerView.addSubview(loadButton)
resultLabel.snp.makeConstraints { (make) in
    make.centerX.equalToSuperview()
    make.left.top.equalToSuperview().offset(30)
    make.right.equalToSuperview().offset(-30)
    make.height.equalTo(50)
}
loadButton.snp.makeConstraints { (make) in
    make.top.equalTo(resultLabel.snp.bottom).offset(30)
    make.centerX.equalToSuperview()
    make.width.equalTo(100)
    make.height.equalTo(50)
}
loadButton.setTitle("加载", for: .normal)

XCPlaygroundPage.currentPage.liveView = containerView

loadButton.rx
    .tap
    .flatMap(start5SecondTimer)
    .filter{ $0 <= 0 }
    .map { _ in () }
    .flatMap(requestData).bind(to: resultLabel.rx.text)

func start5SecondTimer() -> Observable<Int> {
    let timerSignal = BehaviorRelay<Int>(value: 5)
    
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        let value = timerSignal.value
        if value > 0 {
            timerSignal.accept(value - 1)
        } else {
            timer.invalidate()
        }
    }
    
    return timerSignal.asObservable()
}

func requestData() -> Observable<String> {
    return Observable.create { observer -> Disposable in
        // 假设这里去网络请求了
        observer.onNext("返回的结果")
        return Disposables.create()
    }
}

//: [Next](@next)
