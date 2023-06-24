--Emissary of Harmony
--Emissario dell'Armonia
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,Card.HasVibe,2,2,s.lcheck)
	c:EnableReviveLimit()
	--[[This card can be treated as any Vibe for the Bigbang Summon of a Bigbang monster.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_BIGBANG_VIBE)
	e1:SetValue(VIBE_ALL)
	c:RegisterEffect(e1)
	--[[This card's ATK/DEF are treated as 1500 for the Bigbang Summon of a Bigbang monster.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_BASE_BIGBANG_ATTACK)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_BASE_BIGBANG_DEFENSE)
	c:RegisterEffect(e3)
	--[[If this card is destroyed as Bigbang Material: You can add 1 "Bigbang" Spell/Trap from your Deck to your hand.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(1)
	e4:SetCategory(CATEGORIES_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:HOPT()
	e4:SetCondition(s.thcon)
	e4:SetTarget(aux.SearchTarget(s.filter))
	e4:SetOperation(aux.SearchOperation(s.filter))
	c:RegisterEffect(e4)
end
function s.lcheck(g,lc)
	return g:GetClassCount(Card.GetVibe)==#g
end

--FE4
function s.filter(c)
	return c:IsST() and c:IsSetCard(ARCHE_BIGBANG)
end
--E4
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReason()&(REASON_MATERIAL|REASON_BIGBANG)==REASON_MATERIAL|REASON_BIGBANG
end