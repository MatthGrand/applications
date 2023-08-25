package etcd_test

import (
	"flag"
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
var stsName = flag.String("name", "", "name of the primary statefulset")
var namespace = flag.String("namespace", "", "namespace where the application is running")
var password = flag.String("password", "", "database password for username")

func TestMariaDB(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Etcd Persistence Test Suite")
}
