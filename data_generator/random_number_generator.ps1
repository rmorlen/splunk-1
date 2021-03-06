$splunk_tcp_host = "127.0.0.1"
$splunk_tcp_port = 1514

Function Send-TCPMessage {
    Param (
            [Parameter(Mandatory=$true, Position=0)]
            [ValidateNotNullOrEmpty()]
            [string]
            $EndPoint,
            [Parameter(Mandatory=$true, Position=1)]
            [int]
            $Port,
            [Parameter(Mandatory=$true, Position=2)]
            [string]
            $Message
    )
    Process {
        # Setup connection
        $IP = [System.Net.Dns]::GetHostAddresses($EndPoint)
        $Address = [System.Net.IPAddress]::Parse($IP)
        $Socket = New-Object System.Net.Sockets.TCPClient($Address,$Port)

        # Setup stream wrtier
        $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)

        # Write message to stream
        $Message | % {
            $Writer.WriteLine($_)
            $Writer.Flush()
        }

        # Close connection and stream
        $Stream.Close()
        $Socket.Close()
    }
}

while ($true)
{
    Send-TCPMessage -EndPoint $splunk_tcp_host -Port $splunk_tcp_port -Message "Random number generator starting."
    Start-Sleep -Seconds 1
    Send-TCPMessage -EndPoint $splunk_tcp_host -Port $splunk_tcp_port -Message "Random number successfully generated. random_number=$(Get-Random) random_number_2=$(Get-Random)"
    Start-Sleep -Seconds 5
    Send-TCPMessage -EndPoint $splunk_tcp_host -Port $splunk_tcp_port -Message "Random number generator finishing."
    Start-Sleep -Seconds 60
    Write-Output "Looping..."
}

