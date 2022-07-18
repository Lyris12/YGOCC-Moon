--created by Lyris, art by 塵埃路こまき of Pixiv
--天威の龍人霊
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--mat=1+ Wyrm Effect Monsters
	aux.AddLinkProcedure(c,s.filter,1)
end
function s.filter(c)
	return c:IsRace(RACE_WYRM) and c:IsType(TYPE_EFFECT)
end
