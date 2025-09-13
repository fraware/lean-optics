# Performance Monitoring and SLA Enforcement

This document describes the comprehensive performance monitoring and SLA enforcement system implemented for the lean-optics library.

## Overview

The performance monitoring system provides:
- **Structured metric collection** with detailed timing and throughput measurements
- **Baseline comparison** to detect performance regressions
- **SLA enforcement** with configurable thresholds
- **Automated CI/CD integration** with failure conditions
- **Performance dashboard** for trend analysis
- **Historical tracking** of performance metrics over time

## Components

### 1. Performance Measurement Framework (`bench/Performance.lean`)

The core framework provides:
- `PerformanceMetrics` structure for storing detailed metrics
- `SLAThresholds` configuration for enforcement rules
- `runBenchmark` function for collecting metrics
- `enforceSLA` function for validation and comparison

### 2. Enhanced Benchmark Runner (`bench/EnhancedBench.lean`)

Provides comprehensive benchmark tests:
- Lens operations (get, set, over)
- Prism operations (preview, build)
- Traversal operations
- Composition operations
- Automatic SLA enforcement

### 3. Performance Analyzer (`scripts/performance_analyzer.py`)

Python script for:
- Loading and parsing performance metrics
- Comparing current results with baselines
- Enforcing SLA thresholds
- Generating detailed performance reports
- Detecting regressions and violations

### 4. CI/CD Integration (`.github/workflows/ci.yml`)

Automated performance validation:
- Runs on every push to main branch
- Downloads baseline metrics from artifacts
- Executes performance analysis
- Fails build on SLA violations
- Updates baseline on successful runs
- Stores historical results

### 5. Performance Dashboard (`scripts/performance_dashboard.py`)

Web-based dashboard for:
- Visualizing performance trends over time
- Comparing different test metrics
- Identifying performance patterns
- Monitoring SLA compliance

## Usage

### Running Performance Tests Locally

#### Windows
```cmd
scripts\run_performance_tests.bat
```

#### Linux/macOS
```bash
./scripts/run_performance_tests.sh
```

### Customizing SLA Thresholds

Edit `scripts/sla_thresholds.json`:

```json
{
  "maxAvgTimeMs": 1.0,           // Maximum average time per operation
  "maxTotalTimeMs": 1000,        // Maximum total time for all operations
  "minThroughput": 1000.0,       // Minimum throughput (ops/s)
  "maxMemoryUsage": 1000000,     // Maximum memory usage (bytes)
  "regressionThreshold": 0.1     // Maximum allowed regression (10%)
}
```

### Generating Performance Dashboard

```bash
python scripts/performance_dashboard.py --input-dir . --output dashboard.html
```

## SLA Enforcement

The system enforces the following SLA requirements:

1. **Performance Thresholds**: Each operation must meet minimum performance criteria
2. **Regression Detection**: Performance must not regress beyond configured thresholds
3. **Memory Usage**: Memory consumption must stay within limits
4. **Throughput Requirements**: Minimum operations per second must be maintained

### Failure Conditions

The build will fail if:
- Any operation exceeds maximum time thresholds
- Performance regresses beyond the regression threshold
- Memory usage exceeds limits
- Throughput falls below minimum requirements

## Metrics Collected

For each benchmark test, the system collects:

- **Test Name**: Identifier for the test
- **Operation**: Type of operation being measured
- **Iterations**: Number of iterations performed
- **Total Time**: Total execution time in milliseconds
- **Average Time**: Average time per operation
- **Min/Max Time**: Minimum and maximum operation times
- **Throughput**: Operations per second
- **Memory Usage**: Memory consumption in bytes
- **Timestamp**: When the test was run
- **Lean Version**: Version of Lean used
- **Git Commit**: Commit hash for tracking

## Baseline Management

- **Initial Baseline**: First run creates baseline from current metrics
- **Baseline Updates**: Successful runs update the baseline
- **Historical Storage**: All results are stored as GitHub artifacts
- **Regression Detection**: Current results are compared against baseline

## CI/CD Integration

The performance monitoring is integrated into the CI/CD pipeline:

1. **Trigger**: Runs on every push to main branch
2. **Setup**: Installs Lean, Python, and dependencies
3. **Execution**: Runs enhanced benchmarks
4. **Analysis**: Compares with baseline and enforces SLA
5. **Reporting**: Generates detailed performance reports
6. **Storage**: Saves results and updates baseline
7. **Failure**: Fails build on SLA violations

## Monitoring and Alerting

- **Performance Reports**: Detailed reports generated for each run
- **Dashboard**: Visual dashboard for trend analysis
- **Artifacts**: Historical data stored in GitHub artifacts
- **Notifications**: Build failures notify on SLA violations

## Troubleshooting

### Common Issues

1. **No Baseline Found**: First run creates baseline automatically
2. **Performance Regressions**: Check recent changes and optimize code
3. **Memory Issues**: Monitor memory usage and optimize algorithms
4. **CI Failures**: Check performance reports for specific violations

### Debugging

1. **Local Testing**: Run performance tests locally before pushing
2. **Threshold Adjustment**: Modify SLA thresholds if needed
3. **Baseline Reset**: Delete baseline file to reset from current metrics
4. **Detailed Logs**: Check CI logs for specific error messages

## Best Practices

1. **Regular Monitoring**: Check performance dashboard regularly
2. **Threshold Tuning**: Adjust thresholds based on actual performance
3. **Code Optimization**: Address performance regressions promptly
4. **Baseline Updates**: Keep baseline current with stable performance
5. **Documentation**: Document performance requirements and changes

## Future Enhancements

- **Machine Learning**: Predictive performance analysis
- **Alerting**: Email/Slack notifications for regressions
- **Benchmarking**: More comprehensive benchmark suites
- **Profiling**: Integration with Lean profiler
- **Visualization**: Enhanced dashboard features
