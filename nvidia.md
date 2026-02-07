Check if you have nvidia drivers

```sh
nvidia-smi
```

If not install them

```sh
sudo apt update
sudo apt install -y nvidia-driver-535
sudo reboot
```
Or better with ubuntu-drivers

```sh
ubuntu-drivers devices
sudo ubuntu-drivers autoinstall
```

You must install NVIDIA’s runtime and container toolkit 

```sh
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt install -y nvidia-container-toolkit
```

Configure Docker to use it

```sh
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

Test

```sh
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
```

