//
//  NotificationListView.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/16/23.
//

import UIKit

class NotificationListView: UIView, UITableViewDelegate, UITableViewDataSource {
    private var tableView: UITableView!
    private let cellReuseIdentifier = "notificationCell"
    private var loggedIn: Bool

    init(frame: CGRect, loggedIn: Bool) {
        self.loggedIn = loggedIn
        super.init(frame: frame)
        setupTableView()
        registerCells()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.8) // Use a semi-transparent black background
        tableView.separatorStyle = .singleLine // Use a single line separator style
        tableView.separatorColor = .white // Use white color for the separator
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        tableView.tableFooterView = UIView()
        addSubview(tableView)
    }

    private func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loggedIn ? 10 : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = "Notification \(indexPath.row + 1)"
        cell.textLabel?.textColor = .white // Use white color for the text
        cell.backgroundColor = UIColor.clear // Use a clear background color for cells
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
