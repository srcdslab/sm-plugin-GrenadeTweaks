# GrenadeTweaks

This plugin removes the smoke particles and audio ringing effect from HE grenade explosions.

## Supported games

| Game | Smoke particles | Audio ringing |
| --- | --- | --- |
| CS:GO | Removed | Removed |
| CS:S | Not available (CS:S has no `CHEGrenadeProjectile::GetParticleSystemName` to hook) | Removed |

On CS:S this plugin replaces [NoGrenadeRinging](https://github.com/srcdslab/sm-plugin-NoGrenadeRinging), which can be removed.

## Credits
- BotoX: Creating the NoGrenadeRinging plugin for CS:S, which I ported to CS:GO and included in this plugin
