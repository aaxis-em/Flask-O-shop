FROM python:3.10-slim

# Prevent Python from buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip setuptools wheel

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install OpenTelemetry packages
RUN pip install --no-cache-dir \
    opentelemetry-distro \
    opentelemetry-exporter-otlp \
    opentelemetry-instrumentation-flask \
    opentelemetry-instrumentation-sqlalchemy \
    opentelemetry-instrumentation-requests

# Copy the application
COPY . .

# Flask environment
ENV FLASK_APP=app.py
ENV FLASK_ENV=development

EXPOSE 5000

CMD ["opentelemetry-instrument", "flask", "run", "--host=0.0.0.0", "--port=5000"]

