from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import subprocess

app = FastAPI()

def scan_website(host: str) -> str:
       # Construct the Nmap command with the specified options
    nmap_command = [
        'nmap',
        '-sS',        # SYN scan
        '-sV',        # Service version detection
        '--script=default,version,vuln,ssl-enum-ciphers,ssh-auth-methods,ssh2-enum-algos',
        '-Pn',        # Treat all hosts as online (no host discovery)
        '--open',     # Show only open ports
        '--min-hostgroup', '256',  # Minimum number of hosts per group
        '--min-rate', '5000',      # Minimum scan rate
        '--max-retries', '3',     # Maximum number of retries
        '--script-timeout', '300',# Script timeout in seconds
        '-d',         # Debugging
        '--stylesheet', 'https://raw.githubusercontent.com/Haxxnet/nmap-bootstrap-xsl/main/nmap-bootstrap.xsl',
        '-oA',        # Output in all formats
        'nmap_advanced_portscan', # Base name for output files
        '-vvv',       # Verbosity level
        '-p',         # Ports to scan (this should be provided by the caller)
        host          # Target host
    ]
    

    try:
        result = subprocess.run(nmap_command, capture_output=True, text=True, shell=True)
        return result.stdout
    except Exception as e:
        return str(e)

@app.get("/scan/")
async def scan(url: str):
    host = url.split("//")[-1]
    print(host)
    scan_results = scan_website(host)
    return {"scan_results": scan_results}
