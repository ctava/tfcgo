package tfcgo

// #include <stdlib.h>
// #include "tensorflow/c/c_api.h"
// #cgo CFLAGS: -I/usr/local/include
// #cgo LDFLAGS: -ltensorflow
import "C"

import (
	"unsafe"

	"github.com/golang/protobuf/proto"
	pb "github.com/tensorflow/tensorflow/tensorflow/go/pb/tensorflow/core/framework"
)

//RegisteredOps returns all of the supported TF c/c++ api
func RegisteredOps() (*pb.OpList, error) {
	buf := C.TF_GetAllOpList()
	defer C.TF_DeleteBuffer(buf)
	var (
		list = new(pb.OpList)
		size = int(buf.length)
		// See: https://github.com/golang/go/wiki/cgo#turning-c-arrays-into-go-slices
		data = (*[1 << 30]byte)(unsafe.Pointer(buf.data))[:size:size]
		err  = proto.Unmarshal(data, list)
	)
	return list, err
}
