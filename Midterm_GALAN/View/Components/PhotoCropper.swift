//
//  PhotoCropper.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/18/26.
//

import SwiftUI
import UIKit

struct PhotoCropper: View {
    let image: UIImage
    var isSquare: Bool = false
    var onCancel: () -> Void = {}
    var onSave: (UIImage) -> Void = { _ in }

    private let circleSize: CGFloat = 280

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                Text("Move and Resize")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)

                CroppedPhoto(image: image, size: circleSize, scale: scale, offset: offset)
                    .clipShape(isSquare ? AnyShape(RoundedRectangle(cornerRadius: 10)) : AnyShape(Circle()))
                    .overlay(
                        (isSquare ? AnyShape(RoundedRectangle(cornerRadius: 10)) : AnyShape(Circle()))
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                            .simultaneously(with:
                                MagnifyGesture()
                                    .onChanged { value in
                                        scale = min(max(lastScale * value.magnification, 1), 5)
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                    }
                            )
                    )

                Text("Drag to move, pinch to resize")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.gray)

                HStack(spacing: 15) {
                    SheetButton(title: "Cancel", backgroundColor: Color.gray.opacity(0.4), foregroundColor: .white) {
                        onCancel()
                    }

                    SheetButton(title: "Save") {
                        saveCroppedPhoto()
                    }
                }
                .frame(width: circleSize)
            }
        }
    }
    private func saveCroppedPhoto() {
        let renderer = ImageRenderer(content: CroppedPhoto(image: image, size: circleSize, scale: scale, offset: offset))
        renderer.scale = 3

        if let croppedImage = renderer.uiImage {
            onSave(croppedImage)
        } else {
            onCancel()
        }
    }
}

struct CroppedPhoto: View {
    let image: UIImage
    let size: CGFloat
    let scale: CGFloat
    let offset: CGSize

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .offset(offset)
            .frame(width: size, height: size)
            .clipped()
    }
}

#Preview {
    PhotoCropper(image: UIImage(systemName: "photo") ?? UIImage())
}
