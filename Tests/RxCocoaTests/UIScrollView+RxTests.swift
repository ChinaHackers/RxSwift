//
//  UIScrollView+RxTests.swift
//  Tests
//
//  Created by Suyeol Jeon on 6/8/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import Foundation

import RxSwift
import RxCocoa
import UIKit
import XCTest

class UIScrollViewTests : RxTest {}

extension UIScrollViewTests {

    func testScrollEnabled_False() {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true

        Observable.just(false).bindTo(scrollView.rx.isScrollEnabled).dispose()
        XCTAssertTrue(scrollView.isScrollEnabled == false)
    }

    func testScrollEnabled_True() {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.isScrollEnabled = false

        Observable.just(true).bindTo(scrollView.rx.isScrollEnabled).dispose()
        XCTAssertTrue(scrollView.isScrollEnabled == true)
    }

    func testScrollView_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIScrollView = { UIScrollView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, CGPoint(x: 1, y: 1)) { (view: UIScrollView) in view.rx.contentOffset }
    }

    func testScrollViewDidScroll() {
        let scrollView = UIScrollView()
        var didScroll = false

        let subscription = scrollView.rx.didScroll.subscribe(onNext: {
            didScroll = true
        })

        scrollView.delegate!.scrollViewDidScroll!(scrollView)

        XCTAssertTrue(didScroll)
        subscription.dispose()
    }

    func testScrollViewDidZoom() {
        let scrollView = UIScrollView()
        var didZoom = false

        let subscription = scrollView.rx.didZoom.subscribe(onNext: {
            didZoom = true
        })

        scrollView.delegate!.scrollViewDidZoom!(scrollView)

        XCTAssertTrue(didZoom)
        subscription.dispose()
    }

    func testScrollToTop() {
        let scrollView = UIScrollView()
        var didScrollToTop = false

        let subscription = scrollView.rx.didScrollToTop.subscribe(onNext: {
            didScrollToTop = true
        })

        scrollView.delegate!.scrollViewDidScrollToTop!(scrollView)

        XCTAssertTrue(didScrollToTop)
        subscription.dispose()
    }
}

@objc class MockScrollViewDelegate
    : NSObject
    , UIScrollViewDelegate {}

extension UIScrollViewTests {
    func testSetDelegateUsesWeakReference() {
        let scrollView = UIScrollView()

        var delegateDeallocated = false

        autoreleasepool {
            let delegate = MockScrollViewDelegate()
            _ = scrollView.rx.setDelegate(delegate)

            _ = delegate.rx.deallocated.subscribe(onNext: { _ in
                delegateDeallocated = true
            })

            XCTAssert(delegateDeallocated == false)
        }
        XCTAssert(delegateDeallocated == true)
    }
}

#endif
