//
//  MusicPlayerLandingPage.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

struct HeaderData {
    
    var icon: String
    var title: String
    var dividerColor: UIColor
}

extension UIView {
    
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
        self.layer.insertSublayer(gradient, at: 1)
    }
}

class MusicPlayerLandingPage: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var interactor: MusicPlayerLandingPageInteractor?
    fileprivate let countOfRowsInSection = 1
    fileprivate let countOfSection = 6
    fileprivate var dataSource = [HeaderData]()
    fileprivate var selectedSongCover = ""
    fileprivate let headerSize: CGFloat = 60
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let networkService = NetworkService()
        interactor = MusicPlayerLandingPageInteractor(networkService)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = defaultBackgroundColor
        fillDataSource()
        self.title = "Landing page"
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "UpperCell", bundle: nil), forCellReuseIdentifier: UpperCell.identifier)
        tableView.register(UINib(nibName: "PreferencesCell", bundle: nil), forCellReuseIdentifier: PreferencesCell.identifier)
        tableView.register(UINib(nibName: "TodaysPlaylistCell", bundle: nil), forCellReuseIdentifier: TodaysPlaylistCell.identifier)
        tableView.register(UINib(nibName: "NewReleasesCell", bundle: nil), forCellReuseIdentifier: NewReleasesCell.identifier)
        tableView.register(UINib(nibName: "NewClipsCell", bundle: nil), forCellReuseIdentifier: NewClipsCell.identifier)
        tableView.register(UINib(nibName: "PopularSongsCell", bundle: nil), forCellReuseIdentifier: PopularSongsCell.identifier)
        tableView.register(UINib(nibName: "SectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: SectionHeaderView.identifier)
        configureFloatButtonView()
        interactor?.fetchSong(by: "")
    }
    
    private func configureFloatButtonView() {
        
        let startColorForButton = UIColor(red: 255 / 255, green: 124 / 255 , blue: 7 / 255, alpha: 1)
        let endColorForButton = UIColor(red: 220 / 255, green: 13 / 255 , blue: 49 / 255, alpha: 1)
        let viewForButton = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 130, width: self.view.frame.width, height: 130))
        let btn = UIButton(frame: CGRect(x: viewForButton.frame.width / 2 - 145, y: 5, width: 290, height: 60))
        btn.backgroundColor = .red
        btn.layer.masksToBounds = true
        btn.setTitleColor(.white, for: .normal)
        btn.setAttributedTitle(NSAttributedString(string: "Start free trial", attributes: [NSAttributedStringKey.font : UIFont(name: "Roboto-Bold", size: 27) ?? .boldSystemFont(ofSize: 27), NSAttributedStringKey.foregroundColor : UIColor.white]), for: .normal)
        btn.applyGradient(colours: [startColorForButton, endColorForButton])
        btn.layer.cornerRadius = 30
        btn.addTarget(self, action: #selector(startTrialButtonPressed), for: .touchUpInside)
        
        let lableWithAdditionalInfo = UILabel(frame: CGRect(x: viewForButton.frame.width / 2 - 145, y: btn.frame.height + 3, width: btn.frame.width, height: 60))
        lableWithAdditionalInfo.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore "
        lableWithAdditionalInfo.font = UIFont.systemFont(ofSize: 12)
        lableWithAdditionalInfo.textAlignment = .center
        lableWithAdditionalInfo.numberOfLines = 0
        lableWithAdditionalInfo.textColor = UIColor(red: 74/255, green: 74 / 255, blue: 74 / 255, alpha: 1)
        
        viewForButton.addSubview(btn)
        viewForButton.addSubview(lableWithAdditionalInfo)
        viewForButton.backgroundColor = UIColor(red: 23/255.0, green: 21/255.0, blue: 29/255.0, alpha: 1)
        self.view.addSubview(viewForButton)
    }
    
    @objc func startTrialButtonPressed() {
        performSegue(withIdentifier: "musicWasSelected", sender: self)
    }
    
    private func fillDataSource() {
        
        let lightOrange = UIColor(red: 186/255.0, green: 81/255.0, blue: 49/255.0, alpha:1/1.0)
        let brightPink = UIColor(red: 244/255.0, green:64/255.0, blue:113/255.0, alpha:1/1.0)
        let lightPurple = UIColor(red: 144/255.0, green:19/255.0, blue:254/255.0, alpha:1/1.0)
        let lightBlue = UIColor(red: 53/255.0, green:181/255.0, blue:214/255.0, alpha:1/1.0)
        let pink = UIColor(red: 226/255.0, green:65/255.0, blue:170/255.0, alpha:1/1.0)
        
        dataSource.append(HeaderData(icon: "section1", title: "Customise your Preferences", dividerColor: lightBlue))
        dataSource.append(HeaderData(icon: "section2", title: "Playlists for today", dividerColor: lightPurple))
        dataSource.append(HeaderData(icon: "section3", title: "New Releases", dividerColor: pink))
        dataSource.append(HeaderData(icon: "section4", title: "New Video clips", dividerColor: lightOrange))
        dataSource.append(HeaderData(icon: "section5", title: "Popular Songs", dividerColor: brightPink))
    }
}

extension MusicPlayerLandingPage: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return countOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UpperCell.identifier, for: indexPath) as? UpperCell else {
                return UITableViewCell()
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PreferencesCell.identifier, for: indexPath) as? PreferencesCell else {
                return UITableViewCell()
            }
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TodaysPlaylistCell.identifier, for: indexPath) as? TodaysPlaylistCell else {
                return UITableViewCell()
            }
            return cell
            
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewReleasesCell.identifier, for: indexPath) as? NewReleasesCell else {
                return UITableViewCell()
            }
            cell.handler = self
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewClipsCell.identifier, for: indexPath) as? NewClipsCell else {
                return UITableViewCell()
            }
            return cell
            
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PopularSongsCell.identifier, for: indexPath) as? PopularSongsCell else {
                return UITableViewCell()
            }
            cell.hanlder = self
            self.interactor?.output = cell
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
}

extension MusicPlayerLandingPage: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch indexPath.section {
        case 1:
            return 200
        case 3:
            return 300
        case 4:
            return 200
        case 5:
            return 350
        default:
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        return headerSize
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        footerView.backgroundColor = defaultBackgroundColor
        return footerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        headerView.backgroundColor = defaultBackgroundColor
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.identifier) as? SectionHeaderView else {
            return UIView()
        }
        
        if section == 0 {
            return headerView
        }
        
        header.sectionIconImageView.image = UIImage(named: dataSource[section - 1].icon)
        header.sectionNameLabel.text = dataSource[section - 1].title
        header.dividerView.backgroundColor = dataSource[section - 1].dividerColor
        
        return header
    }
}

extension  MusicPlayerLandingPage: ActionHandler {
    
    func musicWasSelected(with cover: String) {
        performSegue(withIdentifier: "musicWasSelected", sender: self)
    }
}






