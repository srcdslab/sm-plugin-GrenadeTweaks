#include <sourcemod>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Grenade Tweaks",
	author = "Vauff, BotoX",
	description = "Removes smoke particles & audio ringing from HE grenade explosions",
	version = "2.1.0",
	url = "https://github.com/Vauff/GrenadeTweaks"
};

Handle g_hGetParticleSystemName;
Handle g_hDamagedByExplosion;

public void OnPluginStart()
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "gamedata/GrenadeTweaks.games.txt");

	if (!FileExists(path))
		SetFailState("Can't find GrenadeTweaks.games.txt gamedata");

	Handle gameData = LoadGameConfigFile("GrenadeTweaks.games");

	if (gameData == INVALID_HANDLE)
		SetFailState("Can't find GrenadeTweaks.games.txt gamedata");

	// CS:S has no CHEGrenadeProjectile::GetParticleSystemName, so the smoke part only runs on games that have the offset (CS:GO)
	int offset = GameConfGetOffset(gameData, "GetParticleSystemName");

	if (offset != -1)
	{
		g_hGetParticleSystemName = DHookCreate(offset, HookType_Entity, ReturnType_CharPtr, ThisPointer_Ignore, Hook_GetParticleSystemName);
		DHookAddParam(g_hGetParticleSystemName, HookParamType_Int);
		DHookAddParam(g_hGetParticleSystemName, HookParamType_ObjectPtr);

		if (!g_hGetParticleSystemName)
			SetFailState("Failed to setup hook for GetParticleSystemName");
	}

	offset = GameConfGetOffset(gameData, "OnDamagedByExplosion");

	if (offset == -1)
		SetFailState("Can't find OnDamagedByExplosion offset in GrenadeTweaks.games.txt gamedata");

	g_hDamagedByExplosion = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_Ignore, Hook_OnDamagedByExplosion);
	DHookAddParam(g_hDamagedByExplosion, HookParamType_ObjectPtr);

	CloseHandle(gameData);

	if (!g_hDamagedByExplosion)
		SetFailState("Failed to setup hook for OnDamagedByExplosion");

	// Late load
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
			OnClientPutInServer(client);
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (g_hGetParticleSystemName && StrEqual(classname, "hegrenade_projectile"))
		DHookEntity(g_hGetParticleSystemName, false, entity);
}

public void OnClientPutInServer(int client)
{
	DHookEntity(g_hDamagedByExplosion, false, client);
}

//void CCSPlayer::OnDamagedByExplosion(const CTakeDamageInfo &info)
public MRESReturn Hook_OnDamagedByExplosion(DHookParam hParams)
{
	return MRES_Supercede;
}

//const char *CHEGrenadeProjectile::GetParticleSystemName(int pointContents, surfacedata_t *pdata)
public MRESReturn Hook_GetParticleSystemName(DHookReturn hReturn, DHookParam hParams)
{
	int pointContents;
	pointContents = DHookGetParam(hParams, 1);

	if (pointContents & MASK_WATER)
		DHookSetReturnString(hReturn, "explosion_basic_water");
	else
		DHookSetReturnString(hReturn, "explosion_hegrenade_brief");

	return MRES_Supercede;
}
