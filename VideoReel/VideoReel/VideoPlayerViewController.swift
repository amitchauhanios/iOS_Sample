//
//  VideoPlayerViewController.swift
//  VideoReel
//
//  Created by Amit on 24/01/23.
//

import UIKit
import AVFoundation
import Photos

class VideoPlayerViewController: UIViewController {
  
  // var feedsTable: UITableView!
  var feedsTable = UITableView(frame: .zero, style: .plain)
  
  @IBOutlet weak var notificationCountLabel: UILabel!
  
  @objc dynamic var currentIndex = 0
  var oldAndNewIndices = (0,0)
  var previousIndex = 1
  
//  lazy var allPosts = [VideoPost]()
  lazy var refreshControl = UIRefreshControl()
  lazy var pageNo = 1
  lazy var lastPage = 0
  var watchAll = true

  var visibleCellsArr = [VideoPlayerTableViewCell()]
  var indexPathDisplaying = -100
  var lastContentOffset: CGFloat = 0
  var mediaDownloadingLink = URL(string: "")
    
  var selectedTab = 0
  
    var allPosts = ["https://meeturfriends.s3.amazonaws.com/uploads/user/69/posts/2197/video0_1626078371.mov",
                       "https://meeturfriends.s3.amazonaws.com/uploads/user/69/posts/2196/video2_1626078156.mov",
                       "https://meeturfriends.s3.amazonaws.com/uploads/user/69/posts/2167/video0_1626040650.mov",
                       "https://meeturfriends.s3.amazonaws.com/uploads/user/69/posts/2166/video1_1626040538.mov",
                       "https://meeturfriends.s3.amazonaws.com/uploads/user/69/posts/2052/video1_1625862405.mov",
                       "https://meeturfriends.s3.amazonaws.com/uploads/user/69/posts/2052/video0_1625862404.mov",
                       "https://meeturfriends.s3.amazonaws.com/uploads/user/69/posts/2050/video0_1625861986.mov",
                       "https://meeturfriends.s3.amazonaws.com/uploads/user/1209/posts/1960/video0_1625602686.mov",
                       "https://meeturfriends.s3.amazonaws.com/uploads/user/69/posts/1916/video0_1625562069.mov",
                       "https://meeturfriends.s3.amazonaws.com/uploads/user/69/posts/1877/video0_1625548158.mov",
                       "https://meeturfriends.s3.amazonaws.com/uploads/user/69/posts/1826/video0_1625520983.mov",
                       "https://meeturfriends.s3.amazonaws.com/uploads/user/69/posts/1825/video0_1625520817.mov"]

    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    pageNo = 1
    //self.roundCornerTab()
//    getPosts(isFollowing: 0)
    appearance()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    //        if let cell = feedsTable.visibleCells.first as? VideoPlayerTableViewCell {
    //            cell.play()
    //        }
    
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    feedsTable.visibleCells.forEach { cell in
      if cell is VideoPlayerTableViewCell {
        (cell as! VideoPlayerTableViewCell).pause()
        (cell as! VideoPlayerTableViewCell).playerView?.cancelAllLoadingRequest()
      }
    }
    //hideLoader()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //        if let cell = feedsTable.visibleCells.first as? VideoPlayerTableViewCell {
    //            cell.play()
    //        }
    
    self.feedsTable.reloadData()
    NotificationCenter.default.addObserver(self, selector: #selector(self.showLoading), name: VideoPlayerViewNotification.showLoading.notificationName, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.hideLoading), name: VideoPlayerViewNotification.hideLoading.notificationName, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    feedsTable.visibleCells.forEach { cell in
      if cell is VideoPlayerTableViewCell {
        (cell as! VideoPlayerTableViewCell).pause()
      }
    }
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func showLoading() {
    //showLoader()
  }
  
  @objc func hideLoading() {
    //hideLoader()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    feedsTable.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
  }
  
  func appearance() {
    self.navigationController?.navigationBar.isHidden = true
    
    self.viewDidLayoutSubviews()
    //tableview
    feedsTable = UITableView(frame: .zero, style: .plain)
    //        let tableheight = self.view.frame.height - (self.tabBarController?.tabBar.frame.height ?? 0)
    //  feedsTable.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    feedsTable.frame = self.view.bounds
    feedsTable.delegate = self
    feedsTable.dataSource = self
    feedsTable.backgroundColor = .black
    //        feedsTable.translatesAutoresizingMaskIntoConstraints = false  // Enable Auto Layout
    feedsTable.isPagingEnabled = true
    feedsTable.contentInsetAdjustmentBehavior = .never
    feedsTable.showsVerticalScrollIndicator = false
    feedsTable.separatorStyle = .none
    feedsTable.prefetchDataSource = self
    feedsTable.estimatedRowHeight = self.view.bounds.height
    feedsTable.tableFooterView = UIView()
    refreshControl.attributedTitle = NSAttributedString(string: "")
    refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
    feedsTable.addSubview(refreshControl)
    self.view.addSubview(self.feedsTable)
    //        feedsTable.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    //        feedsTable.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    //        feedsTable.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    //        feedsTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    
    feedsTable.register(UINib(nibName: "VideoAdTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoAdTableViewCell")
    feedsTable.register(UINib(nibName: "VideoPlayerTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoPlayerTableViewCell")
  }
  
  //    private func roundCornerTab() {
  //        self.tabBarController?.tabBar.layer.masksToBounds = true
  //        self.tabBarController?.tabBar.isTranslucent = true
  //        self.tabBarController?.tabBar.barStyle = UIBarStyle.default
  //        self.tabBarController?.tabBar.layer.cornerRadius = 20
  //        self.tabBarController?.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  //    }
  
  @objc func refreshTable() {
      pageNo = 1
      if selectedTab == 0{
          self.watchAll = true
      }else{
          self.watchAll = false
      }
//      self.getPosts(isFollowing: selectedTab)
    //        self.getOnlineFriendList()
  }
  
}

extension VideoPlayerViewController{
    
    
}



//MARK:- Custom functions
extension VideoPlayerViewController{
  
    private func shareButtonPressed(postIndex: Int, shortLink: String, downloadingLink: URL) {
        debugPrint("share btn")
    }
  
}

//MARK:- TableView methods
extension VideoPlayerViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if allPosts.count == 0 {
      tableView.backgroundColor = .clear
    } else {
      tableView.backgroundColor = .white
    }
    return allPosts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if let cell = tableView.dequeueReusableCell(withIdentifier: "VideoPlayerTableViewCell") as? VideoPlayerTableViewCell {
        
        cell.layoutSubviews()
        cell.videoPlayerDelegate = self
        cell.videoPlayerTabsDelegate = self
        cell.layoutIfNeeded()
        cell.selectionStyle = .none
          
        cell.noVideosView?.isHidden = true
        
        DispatchQueue.main.async {
            cell.configure(post: self.allPosts[indexPath.row], index: indexPath.row, isWatchAll: self.watchAll)
        }
        
        // Like Post
        cell.likePost = { [unowned self] in
            debugPrint("lokepost action")
        }
        
        // Comment Button Pressed
        cell.commentPost = { [unowned self] in
          
            debugPrint("comment action")
        }
        
        // Shorten URL
        cell.shortenURL = {
            debugPrint("shorten action")
        }
        
        
        //Download file
          cell.downloadFile = {
              debugPrint("download action")

          }
        
        // Goto user profile
        cell.viewProfile = { [unowned self] in
            debugPrint("view profile action")
        }
        
        // Open User Profiles
        cell.viewProfileWithID = { [unowned self] id in
            debugPrint("view profile with id action")
        }
        
        return cell
      }else {
        return UITableViewCell()
      }
    }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return feedsTable.bounds.height
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    //Paging closed
    if allPosts.count < 1 { return }
    let lastItem = allPosts.count - 1
    if (indexPath.row == lastItem) && (pageNo < lastPage) {
      pageNo = pageNo + 1
//      getPosts(isFollowing: selectedTab)
    }
    
    if let cell = cell as? VideoPlayerTableViewCell{
      oldAndNewIndices.1 = indexPath.row
      previousIndex = currentIndex
      currentIndex = indexPath.row
      print("current index>> ",currentIndex)
      if indexPath.row != 0 {
        cell.pause()
      }else{
      }
    }
    
  }
  
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? VideoPlayerTableViewCell {
      cell.pause()
      cell.playerView?.cancelAllLoadingRequest()
    }
  }
  
}
extension VideoPlayerViewController:videoPlayerTabsProtocol{
    func selectedTab(withIndex: Int) {
        pageNo = 1
        selectedTab = withIndex
        if withIndex == 0{
            self.watchAll = true
        }else{
            self.watchAll = false
        }
//        getPosts(isFollowing: withIndex)
    }
    
    
}

extension VideoPlayerViewController:videoPlayerProtocol{
   
    func reportClicked(withId: Int) {
        debugPrint("report click action")
    }
    
    func followUnfollowResult(result: String?) {
        debugPrint("follow unfollow action")
    }
}



extension VideoPlayerViewController: UIScrollViewDelegate {
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    //        let cell2 = self.feedsTable.cellForRow(at: IndexPath(row: self.previousIndex, section: 0)) as? VideoPlayerTableViewCell
    //        cell2?.pause()
    //        print("previousIndex:\(previousIndex)")
    //        let cell = self.feedsTable.cellForRow(at: IndexPath(row: self.currentIndex, section: 0)) as? VideoPlayerTableViewCell
    //        cell?.replay()
    //        print("currentIndex:\(currentIndex)")
    //      //  print("replay:scrollViewDidEndDragging")
    
  }
  
  // This delegate is called when the scrollView will start scrolling
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.lastContentOffset = scrollView.contentOffset.y
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
    self.visibleCellsArr = []
    for cell in self.feedsTable.visibleCells{
      if let VideoCell = cell as? VideoPlayerTableViewCell {
        self.visibleCellsArr.append(VideoCell)
      } else {
        
      }
    }
    
    if visibleCellsArr.count > 0 {
      if (self.lastContentOffset < scrollView.contentOffset.y) {
        // did move up
        if let cell = feedsTable.visibleCells.first as? VideoPlayerTableViewCell {
          cell.pause()
        }
        if let cell = feedsTable.visibleCells.last as? VideoPlayerTableViewCell {
          cell.replay()
        }
      } else if (self.lastContentOffset > scrollView.contentOffset.y) {
        // did move down
        if let cell = feedsTable.visibleCells.last as? VideoPlayerTableViewCell {
          cell.pause()
        }
        if let cell = feedsTable.visibleCells.first as? VideoPlayerTableViewCell {
          cell.replay()
        }
      } else {
        // didn't move
      }
    }
  }
  
}


extension VideoPlayerViewController: UITableViewDataSourcePrefetching {
  func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    //        print("prefetchRowsAt \(indexPaths)")
  }
}

// MARK: - API's
extension VideoPlayerViewController{
  private func downloadFileAPI(url: String, fileName: String, completion: @escaping (_ downloaded: Bool,_ downloadingLink: URL?, _ error: String?)->Void) {
    
    let fileUrl = url
    let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destinationUrl = docsUrl.appendingPathComponent(fileName)
    if(FileManager().fileExists(atPath: destinationUrl.path)){
      print("\n\nfile already exists\n\n")
      completion(true,destinationUrl,nil)
    }
    else{
      //showLoader()
      DispatchQueue.main.async {
        self.view.isUserInteractionEnabled = false
      }
      //DispatchQueue.global(qos: .background).async {
      var request = URLRequest(url: URL(string: fileUrl)!)
      request.httpMethod = "GET"
        URLSession.shared.downloadTask(with: request, completionHandler: {[weak self] (url, response, error) in
        if(error != nil){
          //hideLoader()
          DispatchQueue.main.async {
              self?.view.isUserInteractionEnabled = true
          }
          print("\n\nsome error occured\n\n")
          completion(false,nil,error?.localizedDescription)
          return
        }
        if let response = response as? HTTPURLResponse{
          //hideLoader()
          DispatchQueue.main.async {
              self?.view.isUserInteractionEnabled = true
          }
          if response.statusCode == 200{
            DispatchQueue.main.async {
              if let videoUrl = url{
                  if let videoData = try? Data(contentsOf: videoUrl){
                      if let _ = try? videoData.write(to: destinationUrl, options: Data.WritingOptions.atomic){
                      completion(true,destinationUrl,nil)
                      }
                      else{
                        print("\n\nerror again\n\n")
                        completion(false,nil,error?.localizedDescription)
                      }
                  }else{
                      print("\n\nerror again\n\n")
                      completion(false,nil,error?.localizedDescription)
                  }
              
              }//end if let data
            }//end dispatch main
          }//end if let response.status
        }
      }).resume()
      //}//end dispatch global
    }//end outer else
  }
  
  class func saveVideoToGallery(url: URL, postID : String) {
    //let url = URL(string: URLString)
    
    SaveService.saveVideo(url, itemID: postID) { error in
      if let error = error {
        print("Save video error", error.localizedDescription)
      } else {
        print("Save video Success")
        
      }
    }
  }
}

