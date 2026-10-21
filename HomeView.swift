import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct HomeView: View {
    @AppStorage("lang") private var lang = "km"
    @State private var showImporter = false
    @State private var doc: PDFDocument?
    @State private var showSignature = false
    @State private var signature: UIImage? = SignatureStore.load()
    @State private var shareURL: URL?
    @AppStorage("sigWidth") private var sigWidth = 140.0
    @AppStorage("addDate") private var addDate = false
    @State private var message: LocalizedStringKey?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let doc {
                    PDFPlacementView(document: doc, signature: $signature, width: sigWidth, addDate: addDate)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    VStack(spacing: 8) {
                        HStack { Image(systemName: "textformat.size.smaller"); Slider(value: $sigWidth, in: 80...260); Image(systemName: "textformat.size.larger") }
                        Toggle("add_date", isOn: $addDate)
                    }.padding(.horizontal)
                    HStack(spacing: 12) {
                        bigButton("step_signature", "signature") { showSignature = true }
                        bigButton("step_export", "square.and.arrow.up") { export() }
                            .disabled(signature == nil)
                    }.padding(.horizontal)
                } else {
                    Spacer()
                    Image(systemName: "doc.text.magnifyingglass").font(.system(size: 64)).foregroundStyle(.tint)
                    Text("welcome_title").font(.title2.bold())
                    Text("welcome_hint").multilineTextAlignment(.center).foregroundStyle(.secondary).padding(.horizontal, 32)
                    bigButton("step_open", "folder") { showImporter = true }.padding(.horizontal, 32)
                    Spacer()
                }
                if let message { Text(message).font(.footnote).foregroundStyle(.secondary) }
            }
            .navigationTitle("RASIGN")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("ភាសាខ្មែរ") { lang = "km" }
                        Button("English") { lang = "en" }
                    } label: { Image(systemName: "globe") }
                }
                if doc != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("close") { doc = nil; signature = nil }
                    }
                }
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.pdf]) { result in
                guard case .success(let url) = result else { return }
                let ok = url.startAccessingSecurityScopedResource()
                defer { if ok { url.stopAccessingSecurityScopedResource() } }
                doc = PDFDocument(url: url)
                if doc == nil { message = "error_open" }
            }
            .sheet(isPresented: $showSignature) {
                SignaturePadView { signature = $0; SignatureStore.save($0); showSignature = false }
            }
            .sheet(item: $shareURL) { ShareSheet(url: $0) }
        }
    }

    private func bigButton(_ key: LocalizedStringKey, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(key, systemImage: icon).frame(maxWidth: .infinity).padding(.vertical, 14)
        }.buttonStyle(.borderedProminent).controlSize(.large)
    }

    private func export() {
        guard let doc, signature != nil else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("RASIGN-signed.pdf")
        if doc.write(to: url) { shareURL = url } else { message = "error_save" }
    }
}

extension URL: Identifiable { public var id: String { absoluteString } }

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
