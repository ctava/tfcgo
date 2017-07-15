# What is tfcgo?

tfcgo was born out of necessity. Tensorflow go bindings are slow to progress. Relying on protobufs to generate wrapper code is dependant on the growth of the c/c++ public api - and the underlying framework has much more to offer!
This library will eventually do the hard work bridging the gap between go and the Tensorflow c++ framework. Training a TF machine learning algorithm is possible in go. Please note contributions in this repo will be submitted to the main tensorflow repo.

# Docker Installation
Install Docker:
[https://docs.docker.com/engine/installation/#supported-platforms](Install Docker)

# Build from source
git clone this repo:
`git clone https://github.com/ctava/tfcgo`

```
Run the following commands:
cd tfcgo
docker build -t ctava/tfcgo .
docker run -v /Users/local/path:/container/path -it -p 8888:8888 tfcgo:latest
```
and your in. You now have `tensorflow` + `golang` + `tfcgo` available.

# Running

```
Run the following commands:
docker pull ctava/tfcgo:latest
docker run -it --security-opt=seccomp:unconfined -p 8888:8888 tfcgo:latest
```
--security-opt for the purposes of using delve
and your in. You now have `tensorflow` + `golang` + `tfcgo` available.

# Confirm Golang, Tensorflow and tfcgo installation
```
Run the following commands:
go run versioncheck.go
```
You should see the versions of golang, tensorflow and tfcgo as specified in the docker file.

# Now for the fun stuff
```
go run listops.go
```
You should see a list of all of the ops available in tensorflow

Training
```
go run linear.go
```

Classification
```
go run iris.go
```


# Additional resources
[gopherdata](https://github.com/gopherdata/resources)