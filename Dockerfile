# docker build -t regek/fb-mp-rss:latest .

# Use a slim Ubuntu image as the base
FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory in the container
WORKDIR /app

# Install Python, wget, and necessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    wget \
    gpg \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create directory for APT keys and import Mozilla signing key
RUN install -d -m 0755 /etc/apt/keyrings && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

# Verify the fingerprint of the imported key
RUN gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'

# Add Mozilla APT repository to the sources list
RUN echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

# Set APT preferences for Mozilla repository
RUN echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' | tee /etc/apt/preferences.d/mozilla


# Update package list and install Firefox
RUN apt-get update && \
    apt-get install -y firefox && \
    rm -rf /var/lib/apt/lists/*

# Copy the current directory contents into the container at /app
COPY . /app

# Install Python packages specified in requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Initialize the DB
RUN python3 init_db.py

# Expose the port the app runs on
EXPOSE 5000

# Define environment variable
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Run the application
CMD ["python3", "fb_ad_monitor.py"]

