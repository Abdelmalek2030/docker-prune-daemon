package main

import (
	"testing"
	"time"
)

func TestConfigValidate(t *testing.T) {
	valid := Config{
		Interval:  10 * time.Second,
		Threshold: 80,
		Until:     "24h",
	}
	if err := valid.Validate(); err != nil {
		t.Fatalf("expected valid config, got error: %v", err)
	}

	invalidCases := []Config{
		{Interval: 0, Threshold: 80, Until: "24h"},
		{Interval: 10 * time.Second, Threshold: 0, Until: "24h"},
		{Interval: 10 * time.Second, Threshold: 100, Until: "24h"},
		{Interval: 10 * time.Second, Threshold: 80, Until: ""},
	}

	for i, tc := range invalidCases {
		if err := tc.Validate(); err == nil {
			t.Errorf("case %d: expected validation error for %+v, got nil", i, tc)
		}
	}
}

func TestShouldPrune(t *testing.T) {
	if !ShouldPrune(85, 80) {
		t.Error("expected prune trigger when usage (85) >= threshold (80)")
	}
	if !ShouldPrune(80, 80) {
		t.Error("expected prune trigger when usage (80) == threshold (80)")
	}
	if ShouldPrune(79, 80) {
		t.Error("expected no prune when usage (79) < threshold (80)")
	}
}

func TestDiskUsagePercent(t *testing.T) {
	pct, err := DiskUsagePercent("/")
	if err != nil {
		t.Fatalf("unexpected error inspecting root filesystem: %v", err)
	}
	if pct < 0 || pct > 100 {
		t.Fatalf("expected percentage between 0 and 100, got %d", pct)
	}
}

func BenchmarkDiskUsagePercent(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_, _ = DiskUsagePercent("/")
	}
}
