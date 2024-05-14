import SwiftUI
import Vision
import CoreML
import UIKit

// Step 1: Enum for available colors
enum ItemColor: String, CaseIterable {
    case def = "None"
    case red = "Red"
    case green = "Green"
    case blue = "Blue"
    case yellow = "Yellow"
    case purple = "Purple"
    
    var color: Color {
        switch self {
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
        case .yellow:
            return .yellow
        case .purple:
            return .purple
        case .def:
            return .gray
        }
    }
    
    var indicator: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
    }
}

struct ContentView: View {
    @State private var itemName = ""
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var selectedImg: UIImage?
    @State private var isImgPickerDisplayed = false
    @State private var snappedItem: [(String, String, Date, ItemColor)] = [] // Modified to include color
    @State private var showConfirmSheet = false
    @State private var detectedItem = ""
    @State private var nameOption: NameOption = .detected
    @State private var customItemName: String = ""
    @State private var customNotes: String = ""
    @State private var selectedTag: String = ""
    @State private var selectedColor: ItemColor = .def // Step 2: State for selected color
    @State private var isPopoverDisplayed = false
    @State private var selectedItemIndex: Int?

    enum NameOption {
        case detected
        case custom
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if snappedItem.isEmpty {
                    Section {
                        Text("No items in your Snappy.")
                        Text("Use the ➕ icon to snap and save!")
                    }
                } else {
                    List {
                        ForEach(snappedItem.indices, id: \.self) { index in
                            let item = snappedItem[index]
                            let tag = item.1
                            if tag == selectedTag || selectedTag.isEmpty {
                                let note = extractNoteFromItem(item.0)
                                let color = item.3
                                Section(header: Text("Tag: \(tag)")) {
                                    HStack {
                                        if color != .def { // Show color indicator only if not default
                                            color.indicator
                                        } else {
                                            Circle().frame(width: 10, height: 10) // Empty circle
                                        }
                                        VStack(alignment: .leading) {
                                            Text("\(index + 1). \(item.0)")
                                            if !note.isEmpty {
                                                Text("Note: \(note)")
                                            }
                                        }
                                        Spacer()
                                        Button(action: {
                                            selectedItemIndex = index
                                            isPopoverDisplayed.toggle()
                                        }) {
                                            Image(systemName: "info.circle")
                                        }
                                    }
                                    .contentShape(Rectangle()) // Ensure the whole row is clickable
                                    .onTapGesture {
                                        selectedItemIndex = index
                                        isPopoverDisplayed.toggle()
                                    }
                                    .popover(isPresented: Binding<Bool>(
                                        get: { isPopoverDisplayed && index == selectedItemIndex },
                                        set: { _ in }
                                    ), content: {
                                        PopoverView(note: note, date: item.2, image: selectedImg)
                                    })
                                }
                            }
                        }
                        .onDelete(perform: deleteItem)
                    }
                }
                if selectedImg != nil {
                    Group { }
                    .onChange(of: selectedImg) { newValue in
                        guard let newImg = newValue else {
                            fatalError("Error loading new image")
                        }
                        detect(newImg)
                    }
                }
            }
            .navigationTitle("Snappy 🤳🏼")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            selectedTag = "" // Show all Snappys
                        }) {
                            Label("All items", systemImage: "list.bullet")
                        }
                        ForEach(snappedItem.map { $0.1 }.removingDuplicates(), id: \.self) { tag in
                            Button(action: {
                                selectedTag = tag
                            }) {
                                Label(tag, systemImage: "tag.fill")
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.isImgPickerDisplayed.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: self.$isImgPickerDisplayed, onDismiss: {
                print("detectedItem: \(detectedItem)")
                showConfirmSheet.toggle()
            }) {
                ImagePickerView(selectedImage: self.$selectedImg, sourceType: self.sourceType)
            }
            .sheet(isPresented: self.$showConfirmSheet) {
                VStack {
                    if let uiImage = selectedImg {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                            .onAppear {
                                detect(uiImage)
                            }
                            .onChange(of: selectedImg) { newValue in
                                guard let newImage = newValue else {
                                    fatalError("Error loading image")
                                }
                                detect(newImage)
                            }
                    }
                    Form {
                        Section(header: Text("Add Item")) {
                            Picker("Name", selection: $nameOption) {
                                Text("\(detectedItem)").tag(NameOption.detected)
                                Text("Custom").tag(NameOption.custom)
                            }
                            if nameOption == .custom {
                                TextField("Custom Name", text: $customItemName)
                            }
                            TextField("Notes", text: $customNotes)
                            Picker("Color", selection: $selectedColor) { // Step 3: Color selection
                                ForEach(ItemColor.allCases, id: \.self) { color in
                                    HStack {
                                        Circle()
                                            .fill(color.color)
                                            .frame(width: 10, height: 10)
                                        Text(color.rawValue)
                                    }
                                    .tag(color)
                                }
                            }
                            TextField("Tag", text: $selectedTag)
                        }
                    }
                    Button(action: addItem) {
                        Text("Add to List")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding() // Add padding if needed
                }
            }
        }
    }
    
    func addItem() {
        let newItem: String
        switch nameOption {
        case .detected:
            newItem = detectedItem
        case .custom:
            newItem = customItemName
        }
        let itemWithNotes = "\(newItem)"
        snappedItem.append((itemWithNotes, selectedTag, Date(), selectedColor)) // Modified to include color
        UserDefaults.standard.set(snappedItem.map { "\($0.0)###\($0.1)###\($0.2)###\($0.3.rawValue)" }, forKey: "snapped_itemArray") // Saving in a string format
        customItemName = ""
        customNotes = ""
        selectedTag = ""
        showConfirmSheet.toggle()
    }
    
    func deleteItem(at offsets: IndexSet) {
        snappedItem.remove(atOffsets: offsets)
        UserDefaults.standard.set(snappedItem.map { "\($0.0)###\($0.1)###\($0.2)###\($0.3.rawValue)" }, forKey: "snapped_itemArray") // Saving in a string format
    }
    
    private func detect(_ img: UIImage) {
        guard let ciImage = CIImage(image: img) else {
            fatalError("Cannot convert to CIImage")
        }
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {
            fatalError("Cannot detect ML Model")
        }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Cannot get result")
            }

            if let first = result.first {
                detectedItem = first.identifier.components(separatedBy: ", ")[0].capitalized
            }
        }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    private func extractNoteFromItem(_ item: String) -> String {
        let components = item.components(separatedBy: " - ")
        if components.count > 1 {
            return components[1]
        } else {
            return ""
        }
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(picker: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: ImagePickerView
        @Environment(\.presentationMode) var isPresented
        
        init(picker: ImagePickerView) {
            self.picker = picker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else { return }
            self.picker.selectedImage = selectedImage
            self.picker.isPresented.wrappedValue.dismiss()
        }
    }
}

// Step 5: Custom View for Popover
struct PopoverView: View {
    var note: String
    var date: Date
    var image: UIImage?
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
            }
            Text("Note")
                .font(.title3)
                .padding()
            Text(note)
                .padding()
            Text("Date and Time Added: \(formatDate(date))")
                .font(.subheadline)
                .padding(.bottom)
            Spacer()
        }
        .padding()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy - HH:mm"
        return formatter.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var set = Set<Element>()
        var result = [Element]()
        for item in self {
            if set.insert(item).inserted {
                result.append(item)
            }
        }
        return result
    }
}
