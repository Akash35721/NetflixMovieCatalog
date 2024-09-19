# Use an official Python runtime as the base image
FROM python:3.8.12-slim-buster

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file first to leverage Docker cache
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port used by the Flask app (if it's running on 8080)
EXPOSE 8080

# Command to run the app
CMD ["python3", "app.py"]
