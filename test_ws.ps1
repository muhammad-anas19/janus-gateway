$socket = New-Object System.Net.WebSockets.ClientWebSocket
$uri = New-Object System.Uri("wss://janus-gateway.coolify.arcsip.io/")
$cts = New-Object System.Threading.CancellationTokenSource
$socket.Options.AddSubProtocol("janus-protocol")

try {
    Write-Host "Connecting..."
    $connectTask = $socket.ConnectAsync($uri, $cts.Token)
    $connectTask.Wait()
    Write-Host "Connected. State: $($socket.State)"
    
    if ($socket.State -eq 'Open') {
        # Send a create request
        $message = '{"janus": "create", "transaction": "123"}'
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
        $segment = New-Object System.ArraySegment[byte]($buffer)
        $sendTask = $socket.SendAsync($segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $cts.Token)
        $sendTask.Wait()
        Write-Host "Sent message: $message"
        
        # Receive response
        $rcvBuffer = New-Object byte[] 1024
        $rcvSegment = New-Object System.ArraySegment[byte]($rcvBuffer)
        $result = $socket.ReceiveAsync($rcvSegment, $cts.Token).Result
        $response = [System.Text.Encoding]::UTF8.GetString($rcvBuffer, 0, $result.Count)
        Write-Host "Received: $response"
    }
} catch {
    Write-Error "Connection failed: $_"
} finally {
    if ($socket.State -ne 'Closed') {
        $socket.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Done", $cts.Token).Wait()
    }
    $socket.Dispose()
}
