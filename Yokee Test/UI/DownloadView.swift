import SwiftUI
import Combine

final class DownloadViewModel: ObservableObject, Identifiable {
    private let downloadManager: DownloadManager
    private var cancellables = Set<AnyCancellable>()
    
    let id = UUID()
    var title: String
    var subtitle: String
    @Published var progress: Double
    @Published var size = 0
    @Published var isDownloading = false
    
    var isDownloaded: Bool {
        progress >= 1
    }
    
    private var downloadTask: DownloadTask?
    
    init(downloadManager: DownloadManager, download: Download) {
        self.downloadManager = downloadManager
        
        title = download.title
        subtitle = download.artist
        progress = 0
        
        guard let url = URL(string: download.url) else { return }
        
        downloadTask = downloadManager.addDownload(for: url)
        downloadTask?.progressPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] newProgress in
                self?.progress = newProgress
            }
            .store(in: &cancellables)
        
        downloadTask?.contentLengthPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] newSize in
                self?.size = newSize
            }
            .store(in: &cancellables)
        
        downloadTask?.isDownloadingPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isDownloading in
                self?.isDownloading = isDownloading
            }
            .store(in: &cancellables)
    }
}

struct DownloadView: View {
    @ObservedObject var viewModel: DownloadViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                downloadInfo
                
                Spacer()
                
                if viewModel.isDownloaded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            if viewModel.isDownloading {
                downloadProgress
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    private var downloadInfo: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title)
                .font(.title3)
            .fontWeight(.semibold)
            
            Text(viewModel.subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var downloadProgress: some View {
        HStack {
            ProgressView(value: viewModel.progress, total: 1)
                .progressViewStyle(.linear)
                .frame(maxWidth: 250)
            
            Spacer()
            
            Text("\(viewModel.progress.percentString) of \(viewModel.size.mbString)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct DownloadViewPreviews: PreviewProvider {
    private static let downloadManager = DownloadManager()
    
    private static let viewModel1 = DownloadViewModel(
        downloadManager: downloadManager,
        download: DownloadManager.sampleData[0]
    )
    private static let viewModel2 = DownloadViewModel(
        downloadManager: downloadManager,
        download: DownloadManager.sampleData[1]
    )
    private static let viewModel3 = DownloadViewModel(
        downloadManager: downloadManager,
        download: DownloadManager.sampleData[2]
    )
    
    static var previews: some View {
        VStack {
            DownloadView(viewModel: viewModel1)
            DownloadView(viewModel: viewModel2)
            DownloadView(viewModel: viewModel3)
        }
        .padding()
        .onAppear {
            viewModel2.isDownloading = true
            viewModel2.progress = 0.17
            
            viewModel3.progress = 1
        }
    }
}

