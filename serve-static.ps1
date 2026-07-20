$root = (Resolve-Path $PSScriptRoot).Path
$port = 8000
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

Write-Host "Serving $root at http://localhost:$port/"

$contentTypes = @{
  ".html" = "text/html; charset=utf-8"
  ".htm" = "text/html; charset=utf-8"
  ".css" = "text/css; charset=utf-8"
  ".js" = "application/javascript; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".jpg" = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".png" = "image/png"
  ".gif" = "image/gif"
  ".webp" = "image/webp"
  ".avif" = "image/avif"
  ".svg" = "image/svg+xml"
}

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $requestPath = [System.Web.HttpUtility]::UrlDecode($context.Request.Url.AbsolutePath.TrimStart("/"))

    if ([string]::IsNullOrWhiteSpace($requestPath)) {
      $requestPath = "index/index.html"
    }

    $filePath = Join-Path $root $requestPath

    if ((Test-Path $filePath -PathType Container)) {
      $filePath = Join-Path $filePath "index.html"
    }

    $resolved = $null
    if (Test-Path $filePath -PathType Leaf) {
      $resolved = (Resolve-Path $filePath).Path
    }

    if ($resolved -and $resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
      $bytes = [System.IO.File]::ReadAllBytes($resolved)
      $extension = [System.IO.Path]::GetExtension($resolved).ToLowerInvariant()
      $context.Response.ContentType = $contentTypes[$extension]
      if (-not $context.Response.ContentType) {
        $context.Response.ContentType = "application/octet-stream"
      }
      $context.Response.StatusCode = 200
      $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $message = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
      $context.Response.StatusCode = 404
      $context.Response.ContentType = "text/plain; charset=utf-8"
      $context.Response.OutputStream.Write($message, 0, $message.Length)
    }

    $context.Response.OutputStream.Close()
  }
} finally {
  $listener.Stop()
}
