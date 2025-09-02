# Use an official Python runtime as a parent image
FROM python:3.9-slim-buster

# Set the working directory in the container
# This will be the root of your application inside the container
WORKDIR /app

# Copy requirements.txt and install dependencies first for efficient caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your backend code
COPY backend/ /app/backend/

# Copy your frontend templates and static files
COPY frontend/ /app/frontend/

# Ensure Flask knows where to find templates and static files
# If your app.py is structured to look for 'templates' and 'static'
# directly under its own directory, you might need to adjust paths in app.py
# or symlink them. A common Flask setup expects 'templates' and 'static'
# to be siblings of the app.py file.
# Given your structure, your app.py likely needs to be told where to find them.
# For example, in app.py:
# app = Flask(__name__, template_folder='../frontend', static_folder='../frontend/static')
# Or, if you want to keep the Dockerfile simple and move files:
# COPY frontend/index.html /app/templates/index.html
# COPY frontend/feedback_submitted.html /app/templates/feedback_submitted.html
# COPY frontend/static/ /app/static/
# For simplicity and to match your current structure, let's assume app.py handles paths.

# Expose the port your app runs on (e.g., 8080 for Flask)
EXPOSE 8080

# Define environment variable for Flask
# Point FLASK_APP to the app.py file within the container's structure
ENV FLASK_APP=/app/backend/app.py

# Command to run the application
# Ensure Flask runs from the correct directory or specifies the app path
CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"]
