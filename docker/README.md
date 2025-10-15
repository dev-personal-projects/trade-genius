# Flutter web Docker image

This folder contains artifacts to build a Docker image for the Flutter web build and serve it using nginx.

Build image:

    docker build -f docker/flutter-web.Dockerfile -t tradegenius-web:latest .

Run container:

    docker run --rm -p 8080:80 tradegenius-web:latest

Then open http://localhost:8080

Notes:

- The Dockerfile uses the community `cirrusci/flutter` image to build the web assets and nginx as the final server.
- Containerizing Android/iOS is out of scope here.
