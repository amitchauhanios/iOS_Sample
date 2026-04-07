//
//  VideoPlayerTableViewCell.swift
//  VideoReel
//
//  Created by Amit on 24/01/23.
//

import UIKit
import Foundation
import AVKit
import AVFoundation

protocol videoPlayerProtocol:AnyObject{
    func followUnfollowResult(result:String?)
    func reportClicked(withId:Int)
}

protocol videoPlayerTabsProtocol:AnyObject{
    func selectedTab(withIndex:Int)
}


class VideoPlayerTableViewCell: UITableViewCell {
  
  
  @IBOutlet weak var nameBtn: UIButton!
  @IBOutlet weak var captionLbl: UILabel!
  @IBOutlet weak var btnFollow: UIButton!
  @IBOutlet weak var btnReport: UIButton!
  @IBOutlet weak var btnOptionMore: UIButton!
  @IBOutlet weak var btnFollowing: UIButton!
  @IBOutlet weak var btnWatchAll: UIButton!
    
  @IBOutlet weak var noVideosView: UIView!
    
  @IBOutlet var btnTabs: [UIButton]!
    
    weak var videoPlayerDelegate:videoPlayerProtocol?
    weak var videoPlayerTabsDelegate:videoPlayerTabsProtocol?
  
  @IBOutlet weak var profileImgView: UIImageView!{
    didSet{
      profileImgView.isUserInteractionEnabled = true
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToProfilePage))
      profileImgView.addGestureRecognizer(tapGesture)
    }
  }
  
  @IBOutlet weak var likeBtn: UIButton!
  @IBOutlet weak var commentBtn: UIButton!
  @IBOutlet weak var shareBtn: UIButton!
  @IBOutlet weak var downloadBtn: UIButton!
  @IBOutlet weak var likeCountLbl: UILabel!
  @IBOutlet weak var commentCountLbl: UILabel!
  @IBOutlet weak var shareCountLbl: UILabel!
  @IBOutlet weak var pauseImgView: UIImageView!{
    didSet{
      pauseImgView.alpha = 0
    }
  }
  
  // MARK: - Variables
  
  private(set) var isPlaying = false
  private(set) var liked = false

    
    var playerView: VideoPlayerView?
  var viewProfile: (()->())!
  var viewProfileWithID: ((String)->())!
  var likePost: (()->())!
  var commentPost: (()->())!
  var postComment: (()->())!
  var sharePost: (()->())!
  var shortenURL: (()->())!
  var downloadFile: (()->())!
  var indexNumber = -1
  //    weak var delegate: HomeCellNavigationDelegate?
    
  var isReportHidden = true
  
  // MARK: LIfecycles
  override func prepareForReuse() {
    super.prepareForReuse()
    playerView?.cancelAllLoadingRequest()
//    self.playerView = nil
    resetViewsForReuse()
    print(">>>>>>>>>>>>>>prepareForReuse")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if self.playerView != nil {
      self.playerView?.bounds = self.contentView.frame
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layoutIfNeeded()
    self.layoutSubviews()
    print("Awake from nib called>>>>>>>>>>>>>>")
    selectionStyle = .none
    profileImgView.layer.cornerRadius = self.profileImgView.frame.height/2
    self.profileImgView?.layer.masksToBounds = true
    self.playerView = nil
    DispatchQueue.main.async {
      self.playerView = VideoPlayerView(frame: self.contentView.frame)
      self.contentView.addSubview(self.playerView!)
      self.contentView.sendSubviewToBack(self.playerView!)
    }
    
    let pauseGesture = UITapGestureRecognizer(target: self, action: #selector(handlePause))
    self.contentView.addGestureRecognizer(pauseGesture)
    
  }
  
    func configure(post: String, index: Int, isWatchAll:Bool){
    if self.playerView == nil {
      DispatchQueue.main.async {
        self.playerView = VideoPlayerView(frame: self.contentView.frame)
        self.contentView.addSubview(self.playerView!)
        self.contentView.sendSubviewToBack(self.playerView!)
      }
    }
    self.layoutIfNeeded()
    self.layoutSubviews()

        self.indexNumber = index
    
    nameBtn.setTitle("name", for: .normal)

    
    //Mine insert data
    self.selectionStyle = .none
//    self.profileImgView.sd_setImage(with: URL(string: post.userImage), placeholderImage: #imageLiteral(resourceName: "man"))
    self.captionLbl.text = "Caption"
    self.shareCountLbl.text = "Share"
    
        self.likeCountLbl?.text = "like count"

    
        self.commentCountLbl?.text = "comment count"

        
      
      
        btnWatchAll.backgroundColor = .white
        btnWatchAll.setTitleColor(UIColor.blue, for: .normal)
        btnWatchAll.tintColor = UIColor.brown
        btnFollowing.backgroundColor = .clear
        btnFollowing.setTitleColor(UIColor.white, for: .normal)
        btnFollowing.tintColor = .white

    
    DispatchQueue.main.async { [self] in
      if let vidURl = URL(string: post) {
        print("Vide URl:\(vidURl)")
        let width = Int(self.contentView.frame.width)
        let height = Int(self.contentView.frame.height)
        self.playerView?.configure(url: vidURl, fileExtension: ".mov", size: (width,height))
      }
    }
      self.layoutIfNeeded()
      self.layoutSubviews()
  }
  
  func replay(){
    if !isPlaying {
      playerView?.replay()
      play()
    }
  }
  
  func play() {
    if !isPlaying {
      playerView?.play()
      // print("play:Videocell")
      //            musicLbl.holdScrolling = false
      isPlaying = true
    }
  }
  
  func pause(){
    if isPlaying {
      playerView?.pause()
      //            musicLbl.holdScrolling = true
      isPlaying = false
    }
  }
  
  @objc func handlePause(){
    if isPlaying {
      // Pause video and show pause sign
      UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseIn, animations: { [weak self] in
        guard let self = self else { return }
        self.pauseImgView.alpha = 0.35
        self.pauseImgView.transform = CGAffineTransform.init(scaleX: 0.45, y: 0.45)
      }, completion: { [weak self] _ in
        self?.pause()
      })
    } else {
      // Start video and remove pause sign
      UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
        guard let self = self else { return }
        self.pauseImgView.alpha = 0
      }, completion: { [weak self] _ in
        self?.play()
        self?.pauseImgView.transform = .identity
      })
    }
  }
  
  func resetViewsForReuse(){
    likeBtn.tintColor = .white
    pauseImgView.alpha = 0
  }
    
    @IBAction func followingTaped(_ sender: UIButton) {
        setSeletedTab(sender: sender)
        noVideosView?.isHidden = true
        videoPlayerTabsDelegate?.selectedTab(withIndex: 1)
    }
    @IBAction func watchAllTaped(_ sender: UIButton) {
        setSeletedTab(sender: sender)
        noVideosView.isHidden = true
        videoPlayerTabsDelegate?.selectedTab(withIndex: 0)
        
//        btnWatchAll.backgroundColor = .white
//        btnWatchAll.setTitleColor(UIColor(hexString: "7218C2"), for: .normal)
//        btnWatchAll.tintColor = UIColor(hexString: "7218C2")
//        btnFollowing.backgroundColor = .clear
//        btnFollowing.setTitleColor(UIColor.white, for: .normal)
//        btnFollowing.tintColor = .white
    }
    
    func setSeletedTab(sender:UIButton){
    for btn in btnTabs{
        btn.backgroundColor = .white
    btn.setTitleColor(UIColor.black, for: .normal)
    btn.tintColor = UIColor.cyan
        layoutIfNeeded()
      }
    }
    
    
    
  
  
  // MARK: - Actions
  // Like Video Actions
  @IBAction func likeBtnPressed(_ sender: Any) {
    // Change like count in data object and update labels
    //ActionManager.animateButton(btn: likeBtn, likeTint: .red, unlikeTint: .white)
      debugPrint("like btn pressed")
  }
  
  @objc func likeVideo(){
    if !liked {
      liked = true
      likeBtn.tintColor = .red
    }
  }
  
  // Heart Animation with random angle
  @IBAction func showCommentView(_ sender: Any) {
      debugPrint("coment btn pressed")
  }
  
  @IBAction func shareBtnPressed(_ sender: Any) {
      debugPrint("share btn pressed")
  }
  
  @IBAction func nameBtnPressed(_ sender: UIButton) {
      debugPrint("name btn pressed")
  }
  
  @IBAction func downloadBtnPressed(_ sender: UIButton) {
      debugPrint("download btn pressed")
  }
  
  @objc func navigateToProfilePage(){
      debugPrint("navigateToProfilePage btn pressed")
  }
  
}

//API call
extension VideoPlayerTableViewCell {
    
//    private func videoSharePostCount(index: Int) {
//
//      let parameters = ["post_id": self.allPosts[index].postsId]
//      
//        ApiManager.postAPI(apiHelper.videoSharePostCount, parameters: parameters) { (result, error) in
//        
//        if ActionManager.isSuccessfulResult(result: result, error: error) {
//          print("videoSharePostCount successfully Received")
//        }
//      }
//    }
}

extension VideoPlayerTableViewCell{
    @IBAction func followBtnPressed(_ sender: Any) {
        debugPrint("followBtnPressed btn pressed")

    }
    @IBAction func optionBtnPressed(_ sender: Any) {
        debugPrint("optionBtnPressed btn pressed")
    }
    @IBAction func reportBtnPressed(_ sender: Any) {
        debugPrint("reportBtnPressed btn pressed")
    }
    
}



