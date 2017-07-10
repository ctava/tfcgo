package tfcgo

import (
	"reflect"

	tf "github.com/tensorflow/tensorflow/tensorflow/go"
)

//Square - accepts a tensor of [][]float64 and squares []float64[0]
func Square(t *tf.Tensor) (*tf.Tensor, error) {
	var squaredData [][]float64
	switch reflect.TypeOf(t.Value()).Kind() {
	case reflect.Slice:
		tensorData := t.Value().([][]float64)
		for _, f := range tensorData {
			var square []float64
			square = append(square, f[0]*f[0])
			squaredData = append(squaredData, square)
		}
	}

	tensor, e := tf.NewTensor(squaredData)
	if e != nil {
		return nil, e
	}
	return tensor, nil

}
