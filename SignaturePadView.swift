import SwiftUI

struct SignaturePadView: View {
    var onDone: (UIImage) -> Void
    @State private var lines: [[CGPoint]] = []
    @State private var size: CGSize = .zero
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("sign_here").foregroundStyle(.secondary)
                GeometryReader { geo in
                    Canvas { ctx, _ in
                        for line in lines {
                            var p = Path(); p.addLines(line)
                            ctx.stroke(p, with: .color(.black), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        }
                    }
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.4)))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { v in
                            if v.translation == .zero { lines.append([v.location]) }
                            else { lines[lines.count - 1].append(v.location) }
                        })
                    .onAppear { size = geo.size }
                }
                .frame(height: 260)
                HStack {
                    Button("clear", role: .destructive) { lines = [] }.buttonStyle(.bordered)
                    Button("done") { onDone(render()) }.buttonStyle(.borderedProminent).disabled(lines.isEmpty)
                }.controlSize(.large)
                Spacer()
            }
            .padding()
            .navigationTitle("step_signature")
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("close") { dismiss() } } }
        }
    }

    private func render() -> UIImage {
        let r = ImageRenderer(content:
            Canvas { ctx, _ in
                for line in lines {
                    var p = Path(); p.addLines(line)
                    ctx.stroke(p, with: .color(.black), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                }
            }.frame(width: size.width, height: size.height))
        r.scale = 3
        return r.uiImage ?? UIImage()
    }
}
