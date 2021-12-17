import SwiftUI

class DownloadListViewModel: ObservableObject {
    private let downloadManager: DownloadManager
    
    @Published var downloads: [DownloadViewModel]
    
    @Published var isDownloading = false {
        didSet {
            isDownloading
            ? downloadManager.resume()
            : downloadManager.pause()
        }
    }
    
    var downloadButtonViewModel: DownloadButtonViewModel {
        .init(downloadManager: downloadManager)
    }
    
    init(downloadManager: DownloadManager, downloads: [Download]) {
        self.downloadManager = downloadManager
        self.downloads = downloads.map {
            DownloadViewModel(downloadManager: downloadManager, download: $0)
        }
    }
}

struct DownloadList: View {
    @ObservedObject var viewModel: DownloadListViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.downloads) { download in
                DownloadView(viewModel: download)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DownloadButton(viewModel: viewModel.downloadButtonViewModel)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct DownloadListPreviews: PreviewProvider {
    static var previews: some View {
        DownloadList(
            viewModel: DownloadListViewModel(
                downloadManager: DownloadManager(),
                downloads: DownloadManager.sampleData
            )
        )
    }
}
