# Contributing

Issues and pull requests in Chinese or English are welcome.

For a bug report, include your MacBook model, macOS version, build/signing method, reproduction steps and the exact app error. Share whether `--self-test`, `--renderer-test` and `--probe` succeed where relevant. Remove personal screen content, account information, certificate material and unrelated logs before posting.

Keep changes focused. Run the relevant command-line checks described in the README and report manual testing separately. Sensor compatibility and visual changes require real hardware validation; an offscreen GPU test cannot prove desktop composition works on every Mac.

Do not commit app bundles, build products, signing keys, certificates, provisioning profiles or private logs. Changes to capture should preserve exclusion of the overlay, local-only processing and immediate stopping on sustained failures.

Contributions are distributed under the repository's MIT license. Retain the attribution and license of any third-party code you propose to add.
