import SwiftUI

@main
struct Yokee_TestApp: App {
    let downloadManager = DownloadManager()
    
    var body: some Scene {
        WindowGroup {
            DownloadList(viewModel: DownloadListViewModel(
                downloadManager: downloadManager,
                downloads: DownloadManager.sampleData
            ))
        }
    }
}
