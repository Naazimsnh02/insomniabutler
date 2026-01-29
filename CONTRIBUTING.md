# Contributing to Insomnia Butler

Thank you for your interest in contributing to Insomnia Butler! This guide will help you set up your development environment and get the project running locally.

## 🚀 Development Setup

### Prerequisites

Ensure you have the following installed:
- **Flutter SDK** (Latest stable version)
- **Dart SDK** (Included with Flutter)
- **Docker Desktop** (Required for the Serverpod database)
- **Serverpod CLI**: Install by running `dart pub global activate serverpod_cli`

### 1. Server Configuration (`insomniabutler_server`)

The backend is built with Serverpod. You need to configure the database and secrets before running it.

1.  **Navigate to the server directory:**
    ```bash
    cd insomniabutler_server
    ```

2.  **Setup Passwords & Secrets:**
    The project uses a `passwords.yaml` file to manage secrets, which is git-ignored for security.
    
    -   Copy the template file:
        ```bash
        cp config/passwords.template.yaml config/passwords.yaml
        ```
        *(On Windows PowerShell: `Copy-Item config/passwords.template.yaml config/passwords.yaml`)*
    
    -   **Important:** Open `config/passwords.yaml` and fill in the required values.
        -   **Gemini API Key:** You must provide a valid Google Gemini API key in `geminiApiKey` for the chat features to work.
        -   **Database Passwords:** For local development, the default Docker setup usually works with the defaults provided in the template, but ensure they match your Docker configuration.

3.  **Start Docker Containers:**
    Start the Postgres database and Redis:
    ```bash
    docker-compose up --build --detach
    ```

4.  **Run the Server:**
    ```bash
    dart bin/main.dart --apply-migrations
    ```

### 2. Client Generation

If you modify protocol files in the server (e.g., `.spy.yaml` files), you must regenerate the client code.

```bash
cd insomniabutler_server
serverpod generate
```

### 3. Flutter App Configuration (`insomniabutler_flutter`)

1.  **Navigate to the app directory:**
    ```bash
    cd insomniabutler_flutter
    ```

2.  **Setup Environment Config:**
    The app uses `assets/config.json` to determine which API server to connect to. This file is git-ignored.

    -   Copy the template file:
        ```bash
        cp assets/config.template.json assets/config.json
        ```
        *(On Windows PowerShell: `Copy-Item assets/config.template.json assets/config.json`)*

    -   Open `assets/config.json`. By default, it points to localhost:
        ```json
        {
          "apiUrl": "http://localhost:8080/"
        }
        ```
    -   If you are testing on a physical Android device, you may need to use your machine's local IP address (e.g., `http://192.168.1.5:8080/`) instead of `localhost`.

3.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the App:**
    ```bash
    flutter run
    ```

## 🧪 Running Tests

-   **Server Tests:**
    ```bash
    cd insomniabutler_server
    dart test
    ```
-   **Flutter Tests:**
    ```bash
    cd insomniabutler_flutter
    flutter test
    ```

## 🤝 Contribution Guidelines

-   Please follow the existing code style and conventions.
-   Ensure all secrets are kept in `passwords.yaml` or `.env` and are NOT committed to version control.
-   Write clear commit messages.
