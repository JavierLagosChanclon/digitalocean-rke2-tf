locals {
  certified_image_name = "opensuse-leap-16-0-harv-cloud-image.x86_64.qcow2.bz2"
  certified_image_url  = "https://github.com/rancher/harvester-cloud/releases/download/latest/${local.certified_image_name}"
  certified_image_sum  = "5cc036be8be94c5d6c0034e3444b61498fc82b827bda2369e462ad13ff2d255d4acfb17af24ebfcf1ac8d3450e7fe3074476932e085cee7323572dac6366e57a"
}

resource "null_resource" "download_image" {
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      FILE="${path.cwd}/${local.certified_image_name}"
      EXPECTED_SUM="${local.certified_image_sum}"
      if [ -f "$FILE" ]; then
        echo "File already exists, verifying SHA512..."
        ACTUAL_SUM=$(sha512sum "$FILE" | awk '{print $1}')
        if [ "$ACTUAL_SUM" = "$EXPECTED_SUM" ]; then
          echo "Checksum matches, skipping download"
          exit 0
        else
          echo "Checksum mismatch, re-downloading file"
          rm -f "$FILE"
        fi
      fi
      echo "Downloading certified VHD..."
      curl -L -o "$FILE" "${local.certified_image_url}"
      echo "Verifying SHA512..."
      ACTUAL_SUM=$(sha512sum "$FILE" | awk '{print $1}')
      if [ "$ACTUAL_SUM" != "$EXPECTED_SUM" ]; then
        echo "ERROR: SHA512 checksum mismatch!"
        exit 1
      fi
      echo "SHA512 checksum OK!"
      rm -f "$FILE"
    EOT
  }
}

resource "digitalocean_custom_image" "upload_certified_image" {
  depends_on = [null_resource.download_image]
  name       = "${var.prefix}-opensuse-certified-img"
  url        = local.certified_image_url
  regions    = ["nyc3", var.region]
}
