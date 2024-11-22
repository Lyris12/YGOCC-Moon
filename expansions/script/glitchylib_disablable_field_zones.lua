EFFECT_DISABLE_FIELD_ZONE = 100000344

Auxiliary.DisablableFieldZoneModCodes={
	[73468603]=173468603;	--Set Rotation
	[47404795]=147404795;	--Abyss Actor - Super Producer
	[87498729]=187498729;	--Fallen of the Tistina
	[30676200]=130676200;	--Hero of the Ashened City
	[86239173]=186239173;	--Horned Saurus
	[30680659]=130680659;	--Water Enchantress of the Temple
	[30453613]=130453613;	--Awakening of Veidos
	[25964547]=125964547;	--Dream Mirror Hypnagogia
	[65305978]=165305978;	--Fire King Sanctuary
	[49568943]=149568943;	--Vaylantz World - Shinra Bansho
	[75952542]=175952542;	--Vaylantz World - Konig Wissen	
}

function Auxiliary.DisablableFieldZoneMod(e,tp)
	local g=Duel.GetMatchingGroup(function(c) return aux.DisablableFieldZoneModCodes[c:GetOriginalCode()] end,0,LOCATION_ALL,LOCATION_ALL,nil)
	
	for tc in aux.Next(g) do
		local code=tc:GetOriginalCode()
		local modcode=aux.DisablableFieldZoneModCodes[code]
		tc:ReplaceEffect(modcode,0,0)
	end
end

function Card.IsCanPlaceInFieldZone(c,placing_player,receiving_player)
	receiving_player = receiving_player or placing_player
	return not Duel.IsPlayerAffectedByEffect(receiving_player,EFFECT_DISABLE_FIELD_ZONE)
end

if not aux.DisablableFieldZone then
	aux.DisablableFieldZone=true
	local ge1=Effect.GlobalEffect()
	ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	ge1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	ge1:SetCode(EVENT_PREDRAW)
	ge1:OPT()
	ge1:SetOperation(aux.DisablableFieldZoneMod)
	Duel.register_global_duel_effect_table(ge1,0)
end