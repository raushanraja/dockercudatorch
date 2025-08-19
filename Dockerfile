FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04
COPY --from=ghcr.io/astral-sh/uv:0.4.9 /uv /bin/uv

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3.10-distutils \
    python3-pip \
    git \
    curl \
    wget \
    build-essential \
    cmake curl \
    libopenblas-dev \
    libomp-dev \
    libcurl4-openssl-dev\
    && rm -rf /var/lib/apt/lists/*


# Create symbolic link for python3
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Set the primary working directory to /app
WORKDIR /app

# Create a virtual environment
RUN uv venv /opt/venv

# Copy requirements and install Python dependencies
COPY requirements.txt .

# Install Python dependencies using the uv tool
RUN uv pip install --no-cache-dir -r requirements.txt

# Clone the llama.cpp repository
RUN git clone https://github.com/ggerganov/llama.cpp.git

# Build the quantization tool from llama.cpp
WORKDIR /app/llama.cpp

RUN cmake -B build

# Switch back to the main app directory
WORKDIR /app
