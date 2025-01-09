#!/bin/bash

# Ensure all tools are installed and available in the PATH
required_tools=("suzy" "gau" "gobuster" "nuclei" "supply_chain_tool")
log_file="automation_log.txt"

# Function to check if a tool is installed
check_tools() {
    echo "Checking required tools..."
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "Error: $tool is not installed. Exiting."
            exit 1
        fi
    done
    echo "All required tools are installed."
}

# Function to process a single website
process_website() {
    website="$1"

    echo "Processing $website..." >> "$log_file"

    # Run Suzy
    echo "Running Suzy on $website..." >> "$log_file"
    suzy scan "$website" >> "suzy_${website//./_}.txt" 2>&1 &
    pid_suzy=$!

    # Run gau
    echo "Running gau on $website..." >> "$log_file"
    gau "$website" >> "gau_${website//./_}.txt" 2>&1 &
    pid_gau=$!

    # Run gobuster
    echo "Running gobuster on $website..." >> "$log_file"
    gobuster dir -u "$website" -w /path/to/wordlist.txt -o "gobuster_${website//./_}.txt" 2>&1 &
    pid_gobuster=$!

    # Run nuclei
    echo "Running nuclei on $website..." >> "$log_file"
    nuclei -target "$website" -t /path/to/templates >> "nuclei_${website//./_}.txt" 2>&1 &
    pid_nuclei=$!

    # Run supply chain attack tool
    echo "Running supply chain attack tool on $website..." >> "$log_file"
    supply_chain_tool scan "$website" >> "supply_chain_${website//./_}.txt" 2>&1 &
    pid_supply_chain=$!

    # Wait for all processes to finish
    wait $pid_suzy $pid_gau $pid_gobuster $pid_nuclei $pid_supply_chain

    echo "Completed processing $website at $(date)" >> "$log_file"
}

# Main function to process all websites
process_websites() {
    echo "Starting tool execution at $(date)" >> "$log_file"

    # Process each website in parallel
    for website in "$@"; do
        process_website "$website" &
    done

    wait
    echo "All websites processed at $(date)" >> "$log_file"
}

# Run the script
check_tools

# Prompt the user for websites or read from a file
echo "Enter websites separated by space, or specify a file (e.g., websites.txt):"
read -p "Input: " input

if [[ -f "$input" ]]; then
    # If input is a file, read websites from it
    websites=($(cat "$input"))
else
    # Otherwise, treat input as space-separated websites
    websites=($input)
fi

# Run tools on the provided websites
process_websites "${websites[@]}"

echo "Automation complete. Check logs in $log_file."
