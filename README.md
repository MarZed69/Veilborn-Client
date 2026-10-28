# Veilborn client releases

The login screen displays the release version compiled into the client. It does
not query GitHub at runtime: an installed client must keep its own version even
after a newer release is published. Client and server versions must match exactly.

Save and close Unreal Editor, then prepare a new client release in PowerShell:

```powershell
.\Build-Client.ps1 -Version v0.1.1
```

This stamps the selected repository release version into the shared project's
`VeilbornReleaseVersion.h`, builds the current editor module, then packages a
Development Windows client using VeilbornTestingMap. Output: `out/v0.1.1/Windows`.
It does not upload or publish anything. Upload that Windows build to a release
with the same tag in this repository, and use the same version for the server.

When working from an exact local release tag, `-Version` can be omitted and the
script takes the tag from Git. When preparing a new tag, pass it explicitly.
Never reuse a version for different game builds. Do not stamp versions or build
client/server simultaneously against the same project directory.

`Set-BuildVersion.ps1 -Version v0.1.1` only stamps the source; it does not rebuild
existing packages. Normal editor work starts as `v0.1.0-dev` until a release is
selected; development builds must use the same label on both sides.

The client can show a precise version error when the server supports this
handshake. Older servers may only return Unreal's incompatible-build error;
the login screen also explains that a matching client/server release is needed.
