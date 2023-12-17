--Winter Spirit Elf
--  Idea: Alastar Rainford
--  Script: Shad3


local s,id=GetID()
function s.initial_effect(c)
	--Pos
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_POSITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.a_tg)
	e1:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.b_tg)
	c:RegisterEffect(e2)
	--ATK/DEF
	aux.AddWinterSpiritBattleEffect(c)
end
function s.a_tg(e,c)
	return c:IsFaceup() and c:HasCounter(COUNTER_ICE)
end
function s.b_tg(e,c)
	return c:IsSetCard(ARCHE_WINTER_SPIRIT)
end