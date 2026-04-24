# Going further

Once you've got the basics working, here's how to go deeper.

---

## Private images

By default your container image is public. To keep it private, skip the
"Change visibility" step — but you'll need to give your machines credentials
to pull updates.

Create a GitHub PAT with `read:packages` scope, then bake it into the image:

```dockerfile
RUN --mount=type=secret,id=ghcr_pull_token,required=true \
    TOKEN=$(cat /run/secrets/ghcr_pull_token) && \
    mkdir -p /etc/ostree && \
    printf '{"auths":{"ghcr.io":{"auth":"%s"}}}' \
      "$(printf 'token:%s' "$TOKEN" | base64 -w0)" \
      > /etc/ostree/auth.json && \
    chmod 0600 /etc/ostree/auth.json
```

Pass it into the build in `build.yml`:

```yaml
- uses: docker/build-push-action@v6
  with:
    secrets: |
      ghcr_pull_token=${{ secrets.GHCR_PULL_TOKEN }}
```

Add `GHCR_PULL_TOKEN` under **Settings → Secrets → Actions**.

---

## RHEL base image

Swap the `FROM` line and add Red Hat registry credentials:

```dockerfile
FROM registry.redhat.io/rhel9/rhel-bootc:9.4
```

Add secrets `RH_REGISTRY_USERNAME` and `RH_REGISTRY_PASSWORD` (use a
[registry service account](https://access.redhat.com/terms-based-registry/),
not your personal credentials), then add a login step in `build.yml`:

```yaml
- uses: docker/login-action@v3
  with:
    registry: registry.redhat.io
    username: ${{ secrets.RH_REGISTRY_USERNAME }}
    password: ${{ secrets.RH_REGISTRY_PASSWORD }}
```

---

## More image formats

To build an ISO or VMDK alongside the qcow2, add image types to the
`build-disk-image` job:

```yaml
strategy:
  matrix:
    image_type: [qcow2, iso]
```

Then replace `--type qcow2` in the podman run command with
`--type ${{ matrix.image_type }}`.

---

## Red Hat Image Builder (RHEL customers)

If you have access to [console.redhat.com](https://console.redhat.com),
you can offload disk image builds to Red Hat's infrastructure instead of
running them on GitHub Actions runners. This is faster and supports more
output formats including AMI.

This requires a `RHC_API_KEY` (offline token from console.redhat.com) and
a `REGISTRY_PULL_SECRET` (JSON pull secret for your container registry).
A ready-to-use workflow is available on the
[`rhel-customer` branch](../../tree/rhel-customer) of this template.

---

## Baking in SSH keys

```dockerfile
RUN mkdir -p /usr/ssh && \
    echo "ssh-ed25519 AAAA... you@example.com" \
        >> /usr/ssh/root.keys && \
    chmod 0600 /usr/ssh/root.keys
```

---

## Auto-upgrade on a schedule

Add this to your Containerfile to enable automatic nightly upgrades:

```dockerfile
RUN systemctl enable bootc-fetch-apply-updates.timer
```

---

## Image signing with cosign

See the [cosign documentation](https://docs.sigstore.dev/cosign/overview/)
and the [GitHub Actions cosign guide](https://github.com/sigstore/cosign-installer).
