# Script Non-Distruttivo per Gestione Password
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Clear-Host
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "   GESTORE ACCESSO MOCKUP (MEDIOBANCA PREMIER)      " -ForegroundColor White
Write-Host "====================================================" -ForegroundColor Cyan

$scelta = Read-Host "`nVuoi [1] ABILITARE la Password o [2] DISABILITARLA per accesso libero? (1/2)"
$password = "Mediobanca2026"

# --- INIEZIONI JS/CSS ---

$loginUI = @"
<div id="login-container" style="margin-top: 30px; display: flex; flex-direction: column; align-items: center;">
    <div style="display: flex; gap: 10px;">
        <input type="password" id="pwd" placeholder="Inserisci Password" style="padding: 12px 16px; width: 250px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 15px; outline:none; text-align: center;">
        <button onclick="checkAuth()" style="padding: 12px 24px; background: #202742; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight:500; transition: background 0.3s;">Accedi</button>
    </div>
    <div id="err" style="color: #dc3545; font-size: 13px; margin-top: 15px; display: none; font-weight:500; background: #f8d7da; padding: 8px 16px; border-radius: 4px; border: 1px solid #f5c6cb;"><span class="material-icons" style="font-size:16px; vertical-align:middle; margin-right:4px;">error</span> Password errata. Riprova.</div>
</div>
<script>
    document.getElementById('main-icon').innerText = 'lock_person';
    document.getElementById('main-icon').style.animation = 'none';
    document.getElementById('main-desc').innerText = 'L\'accesso e protetto. Inserire la password fornita per sbloccare i cruscotti.';
    
    function checkAuth() {
        if(document.getElementById('pwd').value === '$password') {
            sessionStorage.setItem('mbp_auth_token', 'true');
            document.body.style.opacity = '0.5';
            document.body.style.pointerEvents = 'none';
            setTimeout(function() { window.location.href = 'tdtin.html'; }, 600);
        } else {
            document.getElementById('err').style.display = 'block';
            document.getElementById('pwd').value = '';
        }
    }
    document.addEventListener('keypress', function(e) { if(e.key === 'Enter') checkAuth(); });
</script>
"@

$authCheckBlock = @"
<script>
    if (sessionStorage.getItem('mbp_auth_token') !== 'true') { window.location.href = 'index.html'; }
    function eseguiLogout() { sessionStorage.removeItem('mbp_auth_token'); window.location.href = 'index.html'; }
</script>
"@

$logoutButton = '<span class="nav-link" onclick="eseguiLogout()" style="color:#fca5a5; margin-left:15px; border-left: 1px solid rgba(255,255,255,0.2); padding-left:15px;"><span class="material-icons">power_settings_new</span> Disconnetti</span>'


# --- ESECUZIONE ---
if ($scelta -eq '1') {
    Write-Host "`n[+] Abilitazione Password in corso..." -ForegroundColor Yellow

    # INIETTA INDEX.HTML
    if (Test-Path "index.html") {
        $idx = [System.IO.File]::ReadAllText("$PSScriptRoot\index.html", [System.Text.Encoding]::UTF8)
        # Sostituisco il redirect automatico "commentandolo" in modo che non parta
        $idx = $idx -replace '(?s).*?\r?\n?', '<script>/* Redirect disabilitato */</script>'
        # Inietto il box di login
        $idx = $idx -replace '\r?\n?', $loginUI
        [System.IO.File]::WriteAllText("$PSScriptRoot\index.html", $idx, [System.Text.Encoding]::UTF8)
    }

    # INIETTA TDT IN e OUT
    foreach ($file in @("tdtin.html", "tdtout.html")) {
        if (Test-Path $file) {
            $content = [System.IO.File]::ReadAllText("$PSScriptRoot\$file", [System.Text.Encoding]::UTF8)
            if ($content -notmatch "AUTH_LOCK") {
                $content = $content -replace '(?i)</title>', "</title>`n$authCheckBlock"
                $content = $content -replace '(?i)(</div>\s*</div>\s*</nav>)', "$logoutButton`n`$1"
                [System.IO.File]::WriteAllText("$PSScriptRoot\$file", $content, [System.Text.Encoding]::UTF8)
            }
        }
    }
    Write-Host "Fatto! Protezione abilitata (Password: $password)`n" -ForegroundColor Green
} 
elseif ($scelta -eq '2') {
    Write-Host "`n[-] Rimozione Password in corso..." -ForegroundColor Cyan

    # RIPRISTINA INDEX.HTML
    if (Test-Path "index.html") {
        $idx = [System.IO.File]::ReadAllText("$PSScriptRoot\index.html", [System.Text.Encoding]::UTF8)
        # Ricreo il blocco di redirect originale sovrascrivendo quello commentato
        $redirectOrig = "`n    <script>`n        window.onload = function() { setTimeout(function() { window.location.href = 'tdtin.html'; }, 1000); };`n    </script>`n    "
        $idx = $idx -replace '(?s).*?\r?\n?', $redirectOrig
        # Rimuovo il box di login ripristinando il placeholder originale
        $idx = $idx -replace '(?s).*?\r?\n?', ''
        [System.IO.File]::WriteAllText("$PSScriptRoot\index.html", $idx, [System.Text.Encoding]::UTF8)
    }

    # RIPRISTINA TDT IN e OUT (Rimuovendo i blocchi di sicurezza)
    foreach ($file in @("tdtin.html", "tdtout.html")) {
        if (Test-Path $file) {
            $content = [System.IO.File]::ReadAllText("$PSScriptRoot\$file", [System.Text.Encoding]::UTF8)
            $content = $content -replace '(?s).*?\r?\n?', ''
            $content = $content -replace '(?s).*?\r?\n?', ''
            [System.IO.File]::WriteAllText("$PSScriptRoot\$file", $content, [System.Text.Encoding]::UTF8)
        }
    }
    Write-Host "Fatto! Accesso completamente libero ripristinato.`n" -ForegroundColor Green
} 
else {
    Write-Host "Scelta non valida." -ForegroundColor Red
}

Read-Host "Premi Invio per chiudere"