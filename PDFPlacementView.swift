import SwiftUI
import PDFKit

/// Shows the PDF; tapping a spot stamps the signature there (as a real PDF annotation).
struct PDFPlacementView: UIViewRepresentable {
    let document: PDFDocument
    @Binding var signature: UIImage?
    var width: CGFloat = 140
    var addDate = false

    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.document = document
        v.autoScales = true
        v.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap(_:))))
        context.coordinator.view = v
        return v
    }
    func updateUIView(_ v: PDFView, context: Context) { context.coordinator.parent = self }
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject {
        var parent: PDFPlacementView
        weak var view: PDFView?
        init(_ p: PDFPlacementView) { parent = p }

        @objc func tap(_ g: UITapGestureRecognizer) {
            guard let view, let img = parent.signature else { return }
            let pt = g.location(in: view)
            guard let page = view.page(for: pt, nearest: true) else { return }
            let p = view.convert(pt, to: page)
            let w = parent.width, h = w * img.size.height / max(img.size.width, 1)
            let rect = CGRect(x: p.x - w / 2, y: p.y - h / 2, width: w, height: h)
            page.addAnnotation(SignatureStamp(bounds: rect, image: img))
            if parent.addDate {
                let f = DateFormatter(); f.dateStyle = .medium; f.locale = Locale(identifier: "en")
                let t = PDFAnnotation(bounds: CGRect(x: rect.minX, y: rect.minY - 16, width: max(w, 100), height: 14),
                                      forType: .freeText, withProperties: nil)
                t.contents = f.string(from: Date())
                t.font = .systemFont(ofSize: 10)
                t.fontColor = .darkGray
                t.color = .clear
                t.border = nil
                page.addAnnotation(t)
            }
        }
    }
}

final class SignatureStamp: PDFAnnotation {
    let image: UIImage
    init(bounds: CGRect, image: UIImage) {
        self.image = image
        super.init(bounds: bounds, forType: .stamp, withProperties: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func draw(with box: PDFDisplayBox, in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        ctx.saveGState()
        ctx.translateBy(x: bounds.minX, y: bounds.maxY)
        ctx.scaleBy(x: 1, y: -1)
        image.draw(in: CGRect(origin: .zero, size: bounds.size))
        ctx.restoreGState()
        UIGraphicsPopContext()
    }
}
