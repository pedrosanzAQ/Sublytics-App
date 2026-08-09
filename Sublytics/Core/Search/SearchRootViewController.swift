//
//  SearchRootViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 07/05/26.
//

import UIKit
import SwiftUI

enum SearchState {
    case recent
    case suggestions([SubscriptionModel])
    case results([SubscriptionModel])
    case empty
}

class SearchRootViewController: HeaderViewController {
    private let searchHeader = SearchHeaderViewExtentended()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let selectionView = UIView()
    
    private var state: SearchState = .recent {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var viewmodel: SearchRootViewModel
    
    init(viewmodel: SearchRootViewModel) {
        self.viewmodel = viewmodel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let totalHeaderHeight = headerView.contentHeight + view.safeAreaInsets.top
        
        if tableView.contentInset.top != totalHeaderHeight {
            tableView.contentInset = UIEdgeInsets(top: totalHeaderHeight, left: 0, bottom: 0, right: 0)
            
            if lastOffset == 0 {
                tableView.contentOffset = CGPoint(x: 0, y: -totalHeaderHeight)
                lastOffset = -totalHeaderHeight
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewmodel.initialQuery == nil && headerView.alpha == 0 {
            headerView.alpha = 0
            headerView.transform = CGAffineTransform(translationX: 0, y: -20)
            
            UIView.animate(withDuration: 0.2, delay: 0.05, options: .curveEaseOut) { [weak self] in
                guard let self else { return }
                self.headerView.alpha = 1
                self.headerView.transform = .identity
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewmodel.initialQuery == nil {
            searchHeader.searchTextField.becomeFirstResponder()
        } else {
            searchHeader.searchTextField.resignFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        self.setCustomHeader(searchHeader)
        searchHeader.searchDelegate = self
        tableView.dataSource = self
        tableView.delegate = self
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        setupLayout()
        
        self.headerScrollView = tableView
        selectionView.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.0)
        
        if let query = viewmodel.initialQuery {
            searchHeader.updateTextfield(query)
            showFinalResults(query: query)
        } else {
            searchHeader.updateTextfield("")
            state = .recent
        }
        
        observeViewModel()
        bringHeaderToFront()
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        view.bringSubviewToFront(headerView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        tableView.register(SearchResultCellTableViewCell.self, forCellReuseIdentifier: "ResultCell")
        tableView.separatorColor = .backgroundColor
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .backgroundColor
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func observeViewModel() {
        withObservationTracking {
            
            if let query = viewmodel.initialQuery {
                searchHeader.updateTextfield(query)
                showFinalResults(query: query)
            } else {
                searchHeader.updateTextfield("")
                state = .recent
            }
            
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.observeViewModel()
            }
        }
    }
    
    private func performSearch(query: String) {
        let (trimmed, filtered) = filterSubscriptions(by: query)
        
        guard !trimmed.isEmpty else {
            state = .recent
            return
        }
        
        state = filtered.isEmpty ? .empty : .suggestions(filtered)
    }
    
    private func showFinalResults(query: String) {
        let (trimmed, filtered) = filterSubscriptions(by: query)
        
        guard !trimmed.isEmpty else {
            state = .recent
            return
        }
        
        state = filtered.isEmpty ? .empty : .results(filtered)
    }
    
    private func pushResults(query: String) {
        guard !query.isEmpty else { return }
        
        viewmodel.saveRecents(query: query)
        
        let nextVC = SearchRootViewController(viewmodel: SearchRootViewModel(container: viewmodel.container, query: query))
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func filterSubscriptions(by query: String) -> (trimmed: String, results: [SubscriptionModel]) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return (trimmed, []) }
        
        let filtered = viewmodel.allSubscriptions.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed)
        }
    
        return (trimmed, filtered)
    }
}

extension SearchRootViewController: YTHeaderDelegate {
    func header(_ header: SearchHeaderViewExtentended, didSubmitQuery query: String) {
        pushResults(query: query)
    }
    
    func header(_ header: SearchHeaderViewExtentended, didUpdateText text: String) {
        performSearch(query: text)
    }
    
    func headerDidTapBack(_ header: SearchHeaderViewExtentended) {
        guard let nav = navigationController else { return }
            
        // results
        if viewmodel.initialQuery != nil {
            let vcs = nav.viewControllers
            
            if let previousSearch = vcs.dropLast().last as? SearchRootViewController,
               previousSearch.viewmodel.initialQuery == nil {
                
                if let index = vcs.firstIndex(of: previousSearch),
                   index > 0 {
                    let targetVC = vcs[index - 1]
                    nav.popToViewController(targetVC, animated: true)
                    return
                }
            }
        }
        
        nav.popViewController(animated: true)
    }
}

extension SearchRootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .recent:   return viewmodel.recentSearches.count
        case .suggestions(let items):   return items.count
        case .results(let items): return items.count
        case .empty:    return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if case .results(let items) = state {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! SearchResultCellTableViewCell
            let subscription = items[indexPath.row]
            
            cell.configure(subscription: subscription)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.selectedBackgroundView = selectionView
        cell.backgroundColor = .backgroundColor
        var config = UIListContentConfiguration.valueCell()
        
        switch state {
        case .recent:
            let item = viewmodel.recentSearches[indexPath.row]
            
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular, scale: .medium)
            config.image = UIImage(systemName: "clock", withConfiguration: symbolConfig)
            config.imageToTextPadding = 20
            config.text = item.description
            
            config.textProperties.color = .secondaryText
            config.imageProperties.reservedLayoutSize = CGSize(width: 32, height: 25)
            config.imageProperties.tintColor = .secondaryText
            config.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 26, bottom: 8, trailing: 26)
            

        case .suggestions(let subs):
            let subscription = subs[indexPath.row]
            
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular, scale: .medium)
            config.image = UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig)
            config.text = subscription.title
            config.secondaryText = subscription.category
            config.imageToTextPadding = 20
            
            config.imageProperties.reservedLayoutSize = CGSize(width: 32, height: 25)
            config.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 26, bottom: 8, trailing: 26)
            config.textProperties.color = .secondaryText
            config.secondaryTextProperties.color = .systemBlue.withAlphaComponent(0.8)
            config.imageProperties.tintColor = .secondaryText
            
        case .empty:
            config.text = "No matches found"
            config.textProperties.alignment = .center 
            config.textProperties.color = .secondaryText
            config.textProperties.font = .systemFont(ofSize: 16, weight: .medium)
            config.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 28, leading: 20, bottom: 20, trailing: 20)
            
        case .results: break
        }
        
        cell.contentConfiguration = config
        return cell
    }
}

extension SearchRootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch state {
        case .recent:
            let query = viewmodel.recentSearches[indexPath.row]
            searchHeader.updateTextfield(query)
            pushResults(query: query)
            
        case .suggestions(let subs):
            let selectedSub = subs[indexPath.row]
            pushResults(query: selectedSub.title)
            
        case .results(let subs):
            let selected = subs[indexPath.row]
            let vm = EditSubscriptionViewModel(container: viewmodel.container, subscription: selected)
            let editVC = EditSubscriptionViewController(viewmodel: vm)

            editVC.onDismissRequested = { [weak editVC] in
                editVC?.dismiss(animated: true)
            }
            
            editVC.modalPresentationStyle = .fullScreen
            present(editVC, animated: true)
            
        case .empty: break
        }
    }
}

#Preview("SearchViewController Flow") {
    let container = DevPreview.shared.container
    
    VCPreview {
        let rootVC = SearchRootViewController(viewmodel: SearchRootViewModel(container: container))
        
        let navController = UINavigationController(rootViewController: rootVC)
        navController.isNavigationBarHidden = true
        
        return navController
    }
    .ignoresSafeArea()
}
