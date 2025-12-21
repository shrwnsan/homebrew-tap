# Performance & Benchmarks

## Benchmarks

### Current Performance (v1.4.0+)
- **Single package**: 3.2-3.5 seconds average
- **13 packages**: 45-50 seconds (parallel processing)
- **Latest version**: 75% faster than original
- **Previous version**: 2+ minutes (with race conditions)

### Performance Improvements Timeline
- **v1.4.0**: Auto-discovery system, 75% speed improvement
- **v1.3.0**: Fixed parallel processing race conditions
- **v1.2.0**: Added npm integration with optimized caching
- **v1.1.0**: Implemented parallel processing
- **v1.0.0**: Initial release (sequential processing)

## Parallel Processing

### Example Output
```bash
brew-change -a
# Outdated packages:
# package1 1.0.0 -> 1.1.0
# package2 2.0.0 -> 2.1.0
# ...
#
# Found 13 outdated packages. Would you like to see detailed changelog information? (y/N)
# y
#
# Processing changelog for 13 packages in parallel (max 8 jobs)...
#
# 📦 package1: 1.0.0 → 1.1.0 (2 days ago)
# 📋 Release 1.1.0
# - Bug fixes and improvements
#
# ---
# 📦 package2: 2.0.0 → 2.1.0 (1 day ago)
# 📋 Release 2.1.0
# - New features added
#
# ---
# ...and so on
```

### Job Calculation
- **Default**: Auto-calculated based on system resources
- **Maximum**: 1.5x calculated value (to prevent API rate limiting)
- **Factors considered**:
  - CPU cores (primary factor)
  - Available memory (1 job per 2GB RAM minimum)
  - Hard maximum of 8 jobs to prevent API throttling

## Performance Optimizations

### Caching System
- **Duration**: 1 hour for API responses
- **Location**: `~/.cache/brew-change/` (configurable)
- **Scope**: Release data, package metadata, API responses
- **Invalidation**: Automatic expiration after cache duration

### Network Optimizations
- **Timeout protection**: 5 seconds per curl request
- **Enhanced retry logic**: Exponential backoff with jitter
- **Connection reuse**: Keep-alive for multiple requests
- **Compression**: Automatic gzip decompression

### System Adaptation
- **Load detection**: Automatically adjusts job limits based on system load
- **Memory awareness**: Prevents excessive memory usage
- **Rate limiting**: Built-in protection against API throttling
- **Graceful degradation**: Falls back to sequential processing if needed

## Performance Tuning

### Environment Variables for Performance
```bash
# Reduce parallel jobs for slower systems
export BREW_CHANGE_JOBS=2

# Increase cache duration for slower networks
export BREW_CHANGE_CACHE_DURATION=7200  # 2 hours

# Reduce retry attempts for faster failure
export BREW_CHANGE_MAX_RETRIES=1

# Enable debug mode to identify bottlenecks
export BREW_CHANGE_DEBUG=1
```

### System Recommendations

#### Minimum Requirements
- **CPU**: 2 cores
- **RAM**: 4GB
- **Network**: Stable internet connection
- **OS**: macOS with Homebrew installed

#### Optimal Performance
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Network**: Broadband with low latency
- **SSD**: Faster cache operations

## Performance Monitoring

### Debug Mode
```bash
export BREW_CHANGE_DEBUG=1
brew-change -a
```

Debug output shows:
- Timing information for each operation
- Cache hit/miss statistics
- Parallel job allocation
- Network request details
- Error conditions and recovery

### Performance Metrics
The tool tracks:
- Total execution time
- Per-package processing time
- Cache effectiveness
- Network request counts
- Parallel job utilization

## Bottleneck Analysis

### Common Performance Issues

#### Slow Network
- **Symptoms**: Long delays on API requests
- **Solution**: Increase timeouts, reduce parallel jobs
- **Configuration**: `BREW_CHANGE_TIMEOUT=10`, `BREW_CHANGE_JOBS=2`

#### High System Load
- **Symptoms**: Slow response, timeouts
- **Solution**: Let system auto-adjust or manually reduce jobs
- **Configuration**: `BREW_CHANGE_JOBS=1` (sequential processing)

#### API Rate Limiting
- **Symptoms**: HTTP 429 errors
- **Solution**: Reduce parallel jobs, increase retry delay
- **Configuration**: `BREW_CHANGE_JOBS=1`, `BREW_CHANGE_RETRY_DELAY=5`

#### Cache Invalidation
- **Symptoms**: Slow repeated runs
- **Solution**: Check cache directory permissions
- **Configuration**: `BREW_CHANGE_CACHE_DIR="/tmp/brew-change"`

## Comparison with Alternatives

### vs. Manual Process
- **Manual**: 5-10 minutes per package (research + navigation)
- **brew-change**: 3.5 seconds per package (automated)
- **Improvement**: ~100x faster for multiple packages

### vs. Other Tools
- **brew livecheck**: Requires manual invocation per package
- **brew outdated**: No changelog information
- **brew-change**: Parallel processing + comprehensive data

### Real-world Example
Updating 13 outdated packages:
- **Manual process**: 65-130 minutes
- **Sequential automation**: ~2 minutes (v1.0)
- **Parallel processing**: ~45 seconds (v1.4+)
- **Total improvement**: 87-173x faster than manual