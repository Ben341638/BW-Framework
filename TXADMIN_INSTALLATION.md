# BW Framework - txAdmin Installation Guide

This guide will help you set up your BW Framework server using txAdmin.

## Quick Installation

1. Download and install the latest FiveM server artifacts from [runtime.fivem.net](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/)
2. During setup, select "Remote URL Template" when prompted for deployment type
3. Enter the following URL: `https://raw.githubusercontent.com/yourusername/bw_framework/main/txadmin-recipe.yaml`
4. Follow the on-screen instructions to configure your server

## Manual Installation

If you prefer to set up manually:

1. Create a new FiveM server with txAdmin
2. Select "Local Template" during setup
3. Place the `txadmin-recipe.yaml` and `server.cfg.template` files in your server folder
4. Continue with the txAdmin setup process
5. Fill in all required information (database credentials, server name, etc.)

## Post-Installation

After installation:

1. Configure your database settings in `shared/config.lua`
2. Add your admin identifiers to `server.cfg` (replace `YOUR_LICENSE_HERE` with your FiveM license)
3. Start your server and verify all modules are loading correctly

## Troubleshooting

- If modules fail to load, check the server console for errors
- Verify database connection settings
- Ensure all dependencies are properly installed

## Support

For support, join our Discord: [discord.gg/yourserver](https://discord.gg/yourserver)

## Customization

To customize your server further:
- Edit `shared/config.lua` for framework settings
- Modify module configurations in their respective folders
- Enable additional modules in `server.cfg`