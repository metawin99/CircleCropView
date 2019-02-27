//
//  CropViewController.swift
//  CircleCropView
//
//  Created by Bhavesh Chaudhari on 10/11/18.
//  Copyright © 2018 Bhavesh Chaudhari. All rights reserved.
//

import UIKit

import Foundation
import UIKit
import SnapKit

class CropViewController: UIViewController {
    
    var image: UIImage
    
    let imageView: UIImageView
    let scrollView: UIScrollView
    
    let completion: (UIImage?) -> Void
    private let circleView: CircleCropView
    
    var backButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "back_white"), for: .normal)
        button.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        return button
    }()
    
    
    var okButton : UIButton = {
        let button = UIButton()
        button.setTitle("DONE", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(okClick), for: .touchUpInside)
        return button
    }()
    
    var cancelButton : UIButton = {
        let button = UIButton()
        button.setTitle("CANCEL", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        return button
    }()
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight(rawValue: 10))
        label.text = "" 
        label.textColor = UIColor.white
        label.backgroundColor  = UIColor.clear
        return label
    }()
    
    
    
    init(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        self.image = image
        self.completion = completion
        imageView = UIImageView(image: image)
        scrollView = UIScrollView()
        circleView = CircleCropView()
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Print join to viewDidLoad")
        
        view.addSubview(scrollView)
        view.addSubview(circleView)
        view.addSubview(okButton)
        view.addSubview(cancelButton)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        
        scrollView.backgroundColor = .black
        
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size
        scrollView.delegate = self
        view.backgroundColor = UIColor.white
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view).inset(view.safeAreaInsets)
        }
        
        circleView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView).inset(view.safeAreaInsets)
        }
        
        let viewFrame = self.view.frame.width / 2
        
        okButton.snp.makeConstraints { (make) in
            make.width.equalTo(140)
            make.bottom.equalTo(-30)
            make.height.equalTo(30)
            make.centerX.equalTo(viewFrame + 100)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.width.equalTo(140)
            make.bottom.equalTo(-30)
            make.height.equalTo(30)
            make.centerX.equalTo(viewFrame - 100)
        }
        
        print("pai test", self.view)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.topMargin.equalTo(15)
        }
        
        backButton.snp.makeConstraints { (make) in
            make.leftMargin.topMargin.equalTo(15)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let scrollFrame = scrollView.frame
        let hole = circleView.circleInset
        
        let imSize = image.size
        guard hole.width > 0 else { return }
        
        let verticalRatio = hole.height / imSize.height
        let horizontalRatio = hole.width / imSize.width
        
        scrollView.minimumZoomScale = max(horizontalRatio, verticalRatio)
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = scrollView.minimumZoomScale
        
        let insetHeight = (scrollFrame.height - hole.height) / 2
        let insetWidth = (scrollFrame.width - hole.width) / 2
        scrollView.contentInset = UIEdgeInsets(top: insetHeight, left: insetWidth, bottom: insetHeight, right: insetWidth)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func backClick(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func okClick(sender:UIButton) {
        let rect = self.circleView.circleInset
        let shift = rect.applying(CGAffineTransform(translationX: self.scrollView.contentOffset.x, y: self.scrollView.contentOffset.y))
        let scaled = shift.applying(CGAffineTransform(scaleX: 1.0 / self.scrollView.zoomScale, y: 1.0 / self.scrollView.zoomScale))
        let newImage = self.image.imageCropped(toRect: scaled)
        self.completion(newImage)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelClick(sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension CropViewController: UIScrollViewDelegate {
    func zoomOut() {
        let newScale = scrollView.zoomScale == scrollView.minimumZoomScale ? 0.5 : scrollView.minimumZoomScale
        scrollView.setZoomScale(newScale, animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        //need empty implementation for zooming
    }
}

extension UIImage {
    func imageCropped(toRect rect: CGRect) -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        let imageRef = cgImage.cropping(to: rect)
        let cropped = UIImage(cgImage: imageRef!)
        return cropped
    }
}
