--Winter Spirit Xuan Wu
--Idea: Alastar Rainford
--Original Scripter: Shad3
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),aux.NonTuner(nil),1)
	--disable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.a_tg)
	c:RegisterEffect(e1)
	--atk(def)
	aux.AddWinterSpiritBattleEffect(c)
end
function s.a_tg(e,c)
	return c:GetCounter(COUNTER_ICE)>0 and not c:IsSetCard(ARCHE_WINTER_SPIRIT)
end