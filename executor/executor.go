package executor

import (
	"io"

	"github.com/moby/buildkit/cache"
	"golang.org/x/net/context"
)

type Meta struct {
	Args []string
	Env  []string
	User string
	Cwd  string
	Tty  bool
	// DisableNetworking bool
}

type Mount struct {
	Src      cache.Mountable
	Selector string
	Dest     string
	Readonly bool
}

type Executor interface {
	// TODO: add stdout/err
	Exec(ctx context.Context, meta Meta, rootfs cache.Mountable, mounts []Mount, stdin io.ReadCloser, stdout, stderr io.WriteCloser) error
}
