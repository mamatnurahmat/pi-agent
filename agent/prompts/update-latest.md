Update deployment {{deployment}} di namespace {{namespace}} ke tag release terbaru dari GitHub.

1. Cek tag terbaru dari repo {{deployment}} dengan `~/.pi/agent/bin/gh-latest-tag {{deployment}}`
2. Cek tag yang sedang berjalan di K8s dengan `~/.pi/agent/bin/k8s-latest-tag {{namespace}} {{deployment}}`
3. Jika ada versi baru, konfirmasi ke user dan update dengan `~/.pi/agent/bin/set-image {{namespace}} {{deployment}} <latest_tag>`
4. Verifikasi hasilnya dengan `~/.pi/agent/bin/is-match {{namespace}} {{deployment}}`
