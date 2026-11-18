import PhotosUI
import SwiftUI
import UIKit

/// Prepares a picked photo for storage and OCR: downscales to at most
/// 2000 points on the long edge and compresses to JPEG. Keeps the
/// store small and OCR fast without losing readable text.
enum PhotoStorage {
    static func jpegData(for image: UIImage) -> Data? {
        let maxDimension: CGFloat = 2000
        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let imageToStore: UIImage
        if scale < 1 {
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            imageToStore = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
        } else {
            imageToStore = image
        }
        return imageToStore.jpegData(compressionQuality: 0.8)
    }
}

/// Camera picker. UIImagePickerController wrapped for SwiftUI, camera
/// source only; the photo library uses the system PhotosPicker in
/// `PhotoSlotView`, which needs no library permission prompt.
struct CameraPicker: UIViewControllerRepresentable {
    var onPick: (UIImage) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick, onCancel: onCancel)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onPick: (UIImage) -> Void
        let onCancel: () -> Void

        init(onPick: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onPick = onPick
            self.onCancel = onCancel
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                onPick(image)
            } else {
                onCancel()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onCancel()
        }
    }
}

/// One photo slot (front or back of the ticket, or an evidence photo).
/// Shows the attached photo when there is one, with Take photo and
/// Choose from library buttons. A photo that cannot be read stays
/// attached as evidence either way.
struct PhotoSlotView: View {
    let title: String
    let photoData: Data?
    var onPhoto: (UIImage) -> Void
    var onRemove: (() -> Void)? = nil

    @State private var showingCamera = false
    @State private var libraryItem: PhotosPickerItem?

    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.0)
                .foregroundStyle(.ink)
            if let photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .border(Color.ink.opacity(0.2), width: 1)
            }
            HStack(spacing: 12) {
                if cameraAvailable {
                    AppSecondaryButton(title: photoData == nil ? "Take a photo" : "Retake", systemImage: "camera.fill") {
                        showingCamera = true
                    }
                }
                PhotosPicker(selection: $libraryItem, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                        Text(photoData == nil ? "Choose from library" : "Choose a different photo")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.paper)
                    .foregroundStyle(.ink)
                    .border(Color.ink, width: 1)
                }
                .buttonStyle(.plain)
            }
            if photoData != nil, let onRemove {
                Button("Remove this photo", role: .destructive) {
                    onRemove()
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.signal)
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(
                onPick: { image in
                    showingCamera = false
                    onPhoto(image)
                },
                onCancel: { showingCamera = false }
            )
            .ignoresSafeArea()
        }
        .onChange(of: libraryItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run { onPhoto(image) }
                }
            }
        }
    }
}
