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

class MusicPlayerLandingPage: UITableViewController {
    
    private let countOfRowsInSection = 1
    private let countOfSection = 6
    fileprivate var dataSource = [HeaderData]()
    fileprivate var selectedSongCover = ""
    fileprivate let headerSize: CGFloat = 60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "musicWasSelected" {
            ///
//            guard let destinationNav =  segue.destination as? UINavigationController else {
//                print("Could not cast or its nil")
//                return
//            }
            
//            guard let destinationVc = destinationNav.viewControllers.first as? PlayerViewController else {
//                print("Could not cast or its nil")
//                return
//            }
            
            //destinationVc.albumArtworkImageView.image = UIImage(named: selectedSongCover)
        }
    }
    
    private func fillDataSource() {
        
        let pink = UIColor(red: 199 / 255, green: 21 / 105, blue: 133 / 180, alpha: 1)
        
        dataSource.append(HeaderData(icon: "section1", title: "Customise your Preferences", dividerColor: .blue))
        dataSource.append(HeaderData(icon: "section2", title: "Playlists for today", dividerColor: .purple))
        dataSource.append(HeaderData(icon: "section3", title: "New Releases", dividerColor: pink))
        dataSource.append(HeaderData(icon: "section4", title: "New Video clips", dividerColor: .orange))
        dataSource.append(HeaderData(icon: "section5", title: "Popular Songs", dividerColor: .red))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return countOfSection
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countOfRowsInSection
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        return headerSize
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        footerView.backgroundColor = .black
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        headerView.backgroundColor = .black
        
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








