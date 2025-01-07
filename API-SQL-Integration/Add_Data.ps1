Function Add-Data ($server, $database, $text)
{
    $uid = '[uid]'
    $pass = '[Password]'
    $scon = New-Object System.Data.SqlClient.SqlConnection
    $scon.ConnectionString = "SERVER=$server;DATABASE=$database;User ID = $uid;Password = $pass;"
    $cmd = New-Object System.Data.SqlClient.SqlCommand
    $cmd.Connection = $scon
    $cmd.CommandText = $text
    $cmd.CommandTimeout = 0
    $scon.Open()
    $cmd.ExecuteNonQuery()
    $scon.Close()
    $cmd.Dispose()
    $scon.Dispose()
}