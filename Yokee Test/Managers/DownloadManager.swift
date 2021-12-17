import Foundation
import Combine

struct DownloadTask {
    let task: URLSessionDataTask
    
    var progressPublisher: AnyPublisher<Double, Never> {
        task.progress
            .publisher(for: \.fractionCompleted)
            .eraseToAnyPublisher()
    }
    
    var isDownloadingPublisher: AnyPublisher<Bool, Never> {
        task
            .publisher(for: \.state)
            .map {
                $0 == .running || (task.progress.fractionCompleted > 0 && task.progress.fractionCompleted < 1)
            }
            .eraseToAnyPublisher()
    }
    
    var contentLengthPublisher: AnyPublisher<Int, Never> {
        task
            .publisher(for: \.response)
            .compactMap { $0 }
            .map { Int($0.expectedContentLength) }
            .eraseToAnyPublisher()
    }
    
    var completedPublisher: AnyPublisher<Void, Never> {
        task
            .publisher(for: \.state)
            .filter { $0 == .completed }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    init(task: URLSessionDataTask) {
        self.task = task
    }
    
    func resume() {
        task.resume()
    }
    
    func suspend() {
        task.suspend()
    }
}

class DownloadManager: NSObject {
    private var tasks = [DownloadTask]()
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    func resume() {
        tasks.forEach { $0.resume() }
    }
    
    func pause() {
        tasks.forEach { $0.suspend() }
    }
    
    func addDownload(for url: URL) -> DownloadTask {
        let task = session.dataTask(with: url)
        let downloadTask = DownloadTask(task: task)
        downloadTask.completedPublisher.sink { [weak self] _ in
            guard let index = self?.tasks.firstIndex(where: { $0.task === task }) else { return }
            
            self?.tasks.remove(at: index)
        }
        .store(in: &cancellables)
        tasks.append(downloadTask)
        return downloadTask
    }
    
    static let sampleData = [
        Download(
            title: "Circles",
            artist: "Nero",
            url: "https://drive.google.com/uc?export=download&id=1mBwJhnDAaVGB4UZ-EVuVw0qsndfGhKWB"
        ),
        Download(
            title: "The Thrill",
            artist: "Nero",
            url: "https://drive.google.com/uc?export=download&id=1ee5ZHnXT1Ry3bQe-4TaZVk73bSw-te4W"
        ),
        Download(
            title: "It Comes and It Goes",
            artist: "Nero",
            url: "https://drive.google.com/uc?export=download&id=1bghBVBSeIO2LolHmTrwNHHDiG5vA0EuS"
        ),
        Download(
            title: "Two Minds",
            artist: "Nero",
            url: "https://drive.google.com/uc?export=download&id=1oPiGWhm6cP0yro9JDn41Ay_JZqxxK8J0"
        )
    ]
}
