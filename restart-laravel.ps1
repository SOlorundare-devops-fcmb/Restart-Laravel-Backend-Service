# Define the service name
$serviceName = "LaravelBackendService"

# CPU threshold in percentage
$cpuThreshold = 80

# Interval to check CPU usage in seconds
$checkInterval = 10

# Function to get the CPU usage
function Get-CPUUsage {
    # Get the total CPU usage
    $cpu = Get-Counter '\Processor(_Total)\% Processor Time'
    return $cpu.CounterSamples.CookedValue
}

# Function to restart the Laravel service
function Restart-ServiceIfNeeded {
    param (
        [string]$serviceName,
        [float]$cpuThreshold
    )

    $cpuUsage = Get-CPUUsage

    Write-Output "Current CPU Usage: $cpuUsage%"

    if ($cpuUsage -gt $cpuThreshold) {
        Write-Output "CPU usage exceeds $cpuThreshold%. Restarting service: $serviceName"
        try {
            Restart-Service -Name $serviceName -Force -ErrorAction Stop
            Write-Output "Service '$serviceName' restarted successfully."
        } catch {
            Write-Error "Failed to restart the service '$serviceName'. Error: $_"
        }
    } else {
        Write-Output "CPU usage is within limits. No action needed."
    }
}

# Main loop to continuously monitor CPU usage
while ($true) {
    Restart-ServiceIfNeeded -serviceName $serviceName -cpuThreshold $cpuThreshold
    Start-Sleep -Seconds $checkInterval
}
