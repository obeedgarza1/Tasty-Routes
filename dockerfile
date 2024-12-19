# Use the Python 3.11 slim bullseye base image
FROM python:3.11-slim-bullseye

# Set the working directory
WORKDIR /app

# Install system dependencies, Java, and other required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Download and install Apache Spark only if it's not already installed
RUN SPARK_VERSION="3.4.0" && \
    SPARK_DIR="/opt/spark-${SPARK_VERSION}-bin-hadoop3" && \
    if [ ! -d "$SPARK_DIR" ]; then \
        wget -q https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
        tar -xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz -C /opt && \
        rm spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
        ln -s $SPARK_DIR /opt/spark; \
    fi

# Set environment variables for Spark
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH

# Copy only requirements.txt first to leverage caching for Python dependencies
COPY requirements.txt /app/requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the rest of the application code
COPY . /app

# Expose the Streamlit default port
EXPOSE 8000

# Command to run your Streamlit app on port 8000
CMD ["python3", "-m", "streamlit", "run", "app/main.py", "--server.port=8000", "--server.address=0.0.0.0"]
