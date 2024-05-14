# 🔥 Snappy: The Snap-tastic List Maker! 🛒

![AppIcon~ios-marketing](https://github.com/wafflebytes/Snappy/assets/138287343/40c4bff3-eb15-4ec8-add0-990b29460144){:height="50px" width="50px"}

Introducing Snappy: Leveraging CoreML and SqueezeNet for Advanced Object Recognition.
An innovative iOS application that seamlessly integrates the cutting-edge capabilities of CoreML and the sophisticated architecture of SqueezeNet to deliver a sophisticated and immersive user experience.

## 📝 Features

- 🎥 Camera-powered item detection: Point your camera at any object, and Snappy will use its magical powers to recognize it!
- 📝 Effortless list management: Add detected items to your list with just a tap, making grocery shopping a breeze, by using tagging and colour coding.
- 🔄 Persistence powered by UserDefaults: Your list will be there whenever you need it, even after closing and reopening the app!

## 🎯 Use Cases

Snappy's camera-based item detection and list management capabilities can be adapted to various scenarios:

1. 🛒 Grocery Shopping
2. 🏡 Home Inventory Management
3. 🍽️ Meal Planning
4. 🎁 Gift Registry
5. 🛍️ Garage Sale or Estate Sale Cataloging
6. 🚚 Moving Assistance
7. 🏫 Classroom or Office Supply Management
8. 🧳 Travel Packing
9. 🔨 DIY Project Planning
10. 💼 Asset Management

## 📋 Prerequisites

To enjoy the full Snappy experience, you'll need an iOS device. 
Sorry, Simulator fans – the camera functionality requires a real-world device! 📱

## 🚀 Installation

1. Clone or download this repository to your local machine.
2. Open the `Snappy.xcodeproj` file in Xcode.
3. Connect your iOS device to your Mac.
4. Select your device as the build target in Xcode.
5. Build and run the app on your iOS device.

## 🎬 Usage

1. Launch the Snappy app on your iOS device.
2. Grant camera access permissions when prompted. Snappy needs to see the world! 👀
3. Point your camera at an object you want to detect.
4. Watch as Snappy works its magic to recognize the object! 🧙‍♀️
5. If the detection is accurate, tap "Add to List" to add the item to your shopping list. 📝
6. If the detection is a bit off, you can try again or manually add the item.
7. Your list will be saved using UserDefaults, so you can pick up where you left off! 💾

## 🧠 The brain powering Snappy - SqueezeNet and CoreML

SqueezeNet.mlmodel:
SqueezeNet is renowned for its compact size, with a model size of approximately 0.5MB, making it an efficient choice for mobile applications. The architecture of SqueezeNet incorporates innovative design elements like "Fire Modules" that utilize 1x1 convolutions to compress the input and then expand it using a mix of 1x1 and 3x3 convolutions. This design strategy significantly reduces the number of parameters required for the model while maintaining high accuracy levels. Additionally, SqueezeNet introduces architectural improvements like the SqueezeNext block, which features five convolution layers with batch normalization and ReLU activation. The use of bottleneck layers, smaller convolutions, and residual connections in SqueezeNext enhances the model's efficiency and performance.

CoreML:
CoreML, Apple's machine learning framework, plays a crucial role in integrating machine learning models like SqueezeNet into iOS applications. When working with CoreML, the input data is typically represented as a `CVPixelBuffer`, which is essential for image classification tasks like those performed by SqueezeNet. CoreML simplifies the process of incorporating machine learning models into apps by providing a unified API and optimizing models for efficient inference on Apple devices. In the context of SqueezeNet, CoreML facilitates the seamless execution of the model on iOS devices, ensuring that image inputs are appropriately processed and predictions are generated accurately. The combination of SqueezeNet's compact architecture and CoreML's optimization for Apple hardware enables real-time object recognition with minimal computational resources and optimal performance.

Integration and Usage
To use Snappy, users simply need to launch the app, grant camera access permissions, and point their camera at an object for detection. The app utilizes SqueezeNet v1.1 as the feature extractor, which expects images of 227x227 pixels. The models are built using SqueezeNet as the feature extractor, and the training images are slightly bigger than what SqueezeNet needs, allowing for data augmentation through random crops.

The combination of SqueezeNet's compact architecture and CoreML's optimization for Apple hardware makes it an excellent choice for Snappy's object detection capabilities. The small model size ensures that SqueezeNet can be included in the app's bundle without significantly increasing the app's size, while the efficient inference enabled by CoreML allows for real-time object detection on the user's device without the need for a network connection or external processing power. This ensures that Snappy provides a seamless and responsive experience for users while maintaining the privacy and security of their data.

## 📜 License

Snappy is released under the MIT License, so feel free to play, tweak, and explore! 🎉

## 📬 More

If you encounter any issues, have questions, or want to share your Snappy adventures, drop me a line at [chaitanyajha@icloud.com](mailto:chaitanyajha@icloud.com). I'd love to hear from you! 💌

Remember, object detection is a complex task, and sometimes Snappy might get a little confused. But don't worry, we're learning and improving together! 🤖👨‍💻

Happy snapping! 📸
