FROM ubuntu:22.04 
ENV DEBIAN_FRONTEND=noninteractive 

# Install dependencies including the testcontroller and ping
RUN apt-get update && apt-get install -y \ 
    mininet python3 python3-pip iproute2 \ 
    tshark iperf3 hping3 nmap tcpdump curl nano \
    openvswitch-testcontroller iputils-ping dos2unix && \ 
    apt-get clean 

# Create the symlink for Mininet's controller
RUN ln -s /usr/bin/ovs-testcontroller /usr/bin/ovs-controller

# Install Python packages
RUN pip3 install scikit-learn pandas numpy matplotlib \ 
    scapy tensorflow keras seaborn joblib 

# Setup user
RUN useradd -m student && echo 'student:student' | chpasswd 

# Copy the script, fix the Windows line endings, and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

WORKDIR /home/student 

# --- NEW: Open base directory permissions ---
RUN chmod -R 777 /home/student

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"] 