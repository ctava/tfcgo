# What is tfcgo?

tfcgo was born out of necessity. Tensorflow go bindings are slow to progress. Relying on protobufs to generate wrapper code is dependant on the growth of the c/c++ public api - and the underlying framework has much more to offer!
This library does the hard work bridging the gap between go and the Tensorflow c++ framework. Now, for the first time, training a machine learning algorithm is possible in go! Hope you enjoy using this library and wish to contribute. Contributions are welcome!

# Installation
Install Docker:
[https://docs.docker.com/engine/installation/#supported-platforms](Install Docker)

git clone this repo:
`git clone https://github.com/ctava/tfcgo`

```
Run the following commands:
cd tfcgo
docker build -t tfcgo .
docker run -v /Users/local/path:/container/path -it -p 8888:8888 tfcgo
```
and your in. You now have `tensorflow` + `golang` + `tfcgo` available.

# Confirm Golang, Tensorflow and tfcgo installation
```
Run the following commands:
go run versioncheck.go
```
You should see the versions of golang, tensorflow and tfcgo as specified in the docker file.

# Now for the fun stuff - listops using tfcgo
```
go run listops.go
```
You should see a list of all of the ops available in tensorflow

# Additional resources
[gopherdata](https://github.com/gopherdata/resources)