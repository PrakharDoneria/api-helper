# ApiTesterApp

ApiTesterApp is a Flutter application designed for testing API requests. It allows users to send various types of HTTP requests (GET, POST, PUT, DELETE) and view the responses in a user-friendly interface. Additionally, the app integrates Google Mobile Ads to display banner and interstitial ads.

## Features

- **Send HTTP Requests**: Easily send GET, POST, PUT, and DELETE requests to specified API endpoints.
- **View API Responses**: Display and format responses in JSON format for better readability.
- **Query Parameters**: Add dynamic query parameters for your requests.
- **Google Mobile Ads Integration**: Display banner ads below the response section and show interstitial ads on request submissions.
- **Responsive UI**: A clean, dark-themed user interface that adapts to different screen sizes.

## Getting Started

### Prerequisites

- Flutter SDK installed on your machine. Follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install) if you haven't set it up yet.
- An AdMob account to obtain your AdMob App ID and ad unit IDs. Sign up at [AdMob](https://admob.google.com/).

### Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/PrakharDoneria/api-helper.git
   cd api-helper
   ```

2. **Open the project in your favorite IDE** (e.g., Visual Studio Code, Android Studio).

3. **Add your AdMob App ID**:

   - Open `android/app/src/main/AndroidManifest.xml`.
   - Replace `YOUR_ADMOB_APP_ID` with your actual AdMob App ID.

4. **Add Ad Unit IDs**:

   - Update the ad unit IDs in your code where you initialize the banner and interstitial ads.

5. **Install dependencies**:

   Run the following command to get the required packages:

   ```bash
   flutter pub get
   ```

6. **Run the app**:

   Connect a device or start an emulator and run:

   ```bash
   flutter run
   ```

## Usage

1. **Enter API URL**: Type or paste the API URL you want to test.
2. **Set Request Method**: Select the HTTP method (GET, POST, PUT, DELETE) from the dropdown.
3. **Add Query Parameters**: Use the input fields to add any query parameters you need.
4. **Add Request Body**: If using POST or PUT, you can enter a JSON body for the request.
5. **Send Request**: Click the "Send Request" button to see the response.
6. **View Response**: The response status, headers, and body will be displayed. You can copy the response to the clipboard.

## Contribution

Contributions are welcome! If you have suggestions for improvements or find bugs, please open an issue or submit a pull request.


## Acknowledgements

- [Flutter](https://flutter.dev) - UI toolkit for building natively compiled applications.
- [Google Mobile Ads SDK](https://developers.google.com/admob/android/quick-start) - SDK for displaying ads in mobile apps.