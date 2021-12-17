import SwiftUI

final class DownloadButtonViewModel: ObservableObject {
    private let downloadManager: DownloadManager
    
    @Published var isDownloading: Bool = false {
        didSet {
            isDownloading ? downloadManager.resume() : downloadManager.pause()
        }
    }
    
    init(downloadManager: DownloadManager) {
        self.downloadManager = downloadManager
    }
}

struct DownloadButton: View {
    @ObservedObject var viewModel: DownloadButtonViewModel
    
    private var text: String {
        viewModel.isDownloading
        ? "Pause downloading"
        : "Start downloading"
    }
    
    var body: some View {
        Button {
            viewModel.isDownloading.toggle()
        } label: {
            Text(text)
        }
        .buttonStyle(.borderedProminent)
    }
}

struct DownloadButtonPreviews: PreviewProvider {
    static var previews: some View {
        DownloadButton(
            viewModel: DownloadButtonViewModel(
                downloadManager: DownloadManager()
            )
        )
    }
}

