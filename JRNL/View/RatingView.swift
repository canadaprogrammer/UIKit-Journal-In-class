//
//  RatingView.swift
//  JRNL
//
//  Created by Jungjin Park on 2024-05-16.
//

import UIKit

class RatingView: UIStackView {
    private var ratingButtons: [UIButton] = []
    var rating = 0 {
        // 업데이트될 때마다 실행하기 위해 변수에 property observer 추가
        didSet {
            updateButtonSelectionState()
        }
    }
    private let buttonSize = CGSize(width: 44.0, height: 44.0)
    private let buttonCount = 5
    
    // MARK: - Initialization
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: - Private Methods
    private func setupButtons() {
        // 우선 buttons 를 지움. 기존 버튼 제거
        for button in ratingButtons {
            // 어딘가 메모리에 남아있을 수 있다.
            removeArrangedSubview(button)
            // 그래서 removeFromSuperview호출해서 메모리에서 삭제
            // 이를 호출하지 않으면 메모리 해제시점이 맞지 않을 수도 있다.
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        let filledStar = UIImage(systemName: "star.fill")
        let emptyStar = UIImage(systemName: "star")
        let highlightedStar = UIImage(systemName: "star.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        
        for _ in 0..<buttonCount {
            let button = UIButton()
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            // default 상태에서의 하이라이트
            button.setImage(highlightedStar, for: .highlighted)
            // selected 상태에서의 하이라이트
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            button.translatesAutoresizingMaskIntoConstraints = false
            // constraint 를 켰다(.isActive = true) 컸다(.isActive = false)하기 위해
            button.widthAnchor.constraint(equalToConstant: buttonSize.width).isActive = true
            button.heightAnchor.constraint(equalToConstant: buttonSize.height).isActive = true
            // object-c method 호출하는 구문
            // ratingButtonTapped의 for: UIKit button 이 가지고 있는 이벤트들
            // ratingButtonTapped(button:) :
            // .touchUpInside : 버튼이 눌린다는 느낌
            // addTarget을 호출하므로 rating view 에 있는 함수중에 ratingButtonTapped 를 호출해 달라는 것
            // 콜스택에서 생성하는 함수와 런타임시 생성하는 함수가 있는데
            // 이는 런타임시 생성되고 폰에서 발생하는 행위를 프로그램에 바로 알려주기위해 사용
            // button: 뒤에 값이 없는 것은 파라미터 이름으로 타입을 확인하기 위해 파라미터 이름은 써줘야 하지만 값은 필요없으므로 비워놓는다
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(button)
            ratingButtons.append(button)
        }
    }
    
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    // 이벤트에 걸리기 위해 object-c 사용
    // 런타임함수 시그니처가 필요해서 object-c 함수 사용
    // 버튼 눌릴 때 이벤트 생성
    @objc func ratingButtonTapped(button: UIButton) {
        //버튼을 눌렀을 때 인덱스
        // 해당버튼이 몇 번째 버튼인지 확인
        guard let index = ratingButtons.firstIndex(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
}
