'''
Migrate kcpSettings to finalMask.udp
See https://github.com/XTLS/Xray-core/pull/5560

Old config example:
      "streamSettings": {
        "network": "kcp",
        "kcpSettings": {
          "seed": "123456",
          "header": {
            "type": "dtls"
          }
        }
      },

New config example:
      "streamSettings": {
        "network": "kcp",
        "finalmask": {
          "udp": [
            {
              "type": "header-dtls"
            },
            {
              "type": "mkcp-aes128gcm",
              "settings": {
                "password": "123456"
              }
            }
          ]
        }
      },
'''
import argparse
import json

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="Path to the mKCP configuration file")

    args = parser.parse_args()

    with open(args.file, "r", encoding="utf-8") as f:
        config = json.load(f)

    for side in ["inbounds", "outbounds"]:
        if side not in config.keys():
            continue

        for item in config[side]:
            print(f"Migrating {side}/{item["tag"]}")
            if item["streamSettings"]["network"] != "kcp":
                print("... not kcp network, skipping")
                continue

            kcp_settings = item["streamSettings"].get("kcpSettings")
            if not kcp_settings:
                print("... no kcpSettings found, skipping")
                continue

            seed = kcp_settings.get("seed")
            header = kcp_settings.get("header", {})
            header_type = header.get("type", "")

            if header_type == "wechat_video":
                print("... wechat_video header is renamed to wechat")
                header_type = "wechat"

            print(f"... header type: {header_type}")
            if seed is None:
                print("... no seed found, using mkcp-original, this can be unsafe")
            else:
                print(f"... seed: {seed}")

            item["streamSettings"]["finalmask"] = {
                "udp": [
                    {
                        "type": f"header-{header_type}"
                    },
                    {
                        "type": "mkcp-aes128gcm",
                        "settings": {
                            "password": seed
                        }
                    } if seed is not None else {
                        "type": "mkcp-original"
                    }
                ]
            }

            del item["streamSettings"]["kcpSettings"]

    with open(args.file, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, separators=(",", ": "))
