package batch

import (
	"context"
	"log/slog"
	"sync"
	"time"

	"bwhere/internal/db"
)

const (
	defaultCapacity      = 10000
	defaultFlushSize     = 200
	defaultFlushInterval = 1 * time.Second
	workerCount          = 2
)

// PointCallback is called for each point after successful insert.
type PointCallback func(ctx context.Context, p db.LocationPoint)

type Inserter struct {
	db            *db.DB
	ch            chan db.LocationPoint
	done          chan struct{}
	wg            sync.WaitGroup
	capacity      int
	flushSize     int
	flushInterval time.Duration
	onInsert      PointCallback
}

type Option func(*Inserter)

func WithCapacity(n int) Option {
	return func(i *Inserter) { i.capacity = n }
}

func WithFlushSize(n int) Option {
	return func(i *Inserter) { i.flushSize = n }
}

func WithFlushInterval(d time.Duration) Option {
	return func(i *Inserter) { i.flushInterval = d }
}

func WithPointCallback(cb PointCallback) Option {
	return func(i *Inserter) { i.onInsert = cb }
}

func New(database *db.DB, opts ...Option) *Inserter {
	i := &Inserter{
		db:            database,
		ch:            make(chan db.LocationPoint, defaultCapacity),
		done:          make(chan struct{}),
		capacity:      defaultCapacity,
		flushSize:     defaultFlushSize,
		flushInterval: defaultFlushInterval,
	}
	for _, opt := range opts {
		opt(i)
	}
	i.ch = make(chan db.LocationPoint, i.capacity)
	return i
}

func (i *Inserter) Start(ctx context.Context) {
	for w := 0; w < workerCount; w++ {
		i.wg.Add(1)
		go i.worker(ctx, w)
	}
	slog.Info("batch inserter started", "workers", workerCount, "capacity", i.capacity, "flushSize", i.flushSize)
}

func (i *Inserter) Submit(p db.LocationPoint) {
	select {
	case i.ch <- p:
	default:
		slog.Warn("batch inserter buffer full, dropping point")
	}
}

func (i *Inserter) Stop() {
	close(i.done)
	i.wg.Wait()
	slog.Info("batch inserter stopped")
}

func (i *Inserter) worker(ctx context.Context, id int) {
	defer i.wg.Done()

	batch := make([]db.LocationPoint, 0, i.flushSize)
	timer := time.NewTimer(i.flushInterval)
	defer timer.Stop()

	for {
		select {
		case <-i.done:
			for {
				select {
				case p := <-i.ch:
					batch = append(batch, p)
				default:
					if len(batch) > 0 {
						i.flush(ctx, batch)
					}
					return
				}
			}

		case p := <-i.ch:
			batch = append(batch, p)
			if len(batch) >= i.flushSize {
				i.flush(ctx, batch)
				batch = batch[:0]
				if !timer.Stop() {
					select {
					case <-timer.C:
					default:
					}
				}
				timer.Reset(i.flushInterval)
			}

		case <-timer.C:
			if len(batch) > 0 {
				i.flush(ctx, batch)
				batch = batch[:0]
			}
			timer.Reset(i.flushInterval)
		}
	}
}

func (i *Inserter) flush(ctx context.Context, batch []db.LocationPoint) {
	start := time.Now()
	if err := i.db.BulkInsertLocations(ctx, batch); err != nil {
		slog.Error("batch insert failed", "count", len(batch), "err", err, "elapsed", time.Since(start))
		return
	}
	slog.Debug("batch inserted", "count", len(batch), "elapsed", time.Since(start))

	// Run geofence checks for each point
	if i.onInsert != nil {
		for _, p := range batch {
			i.onInsert(ctx, p)
		}
	}
}

func (i *Inserter) ChannelLen() int {
	return len(i.ch)
}
