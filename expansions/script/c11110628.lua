--Lifeweaver's Feng Shui
--Feng Shui della Vitatessitrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--[[During your Main Phase, you can Normal Summon 1 "Lifeweaver" monster in addition to your Normal Summon/Set. (You can only gain this effect once per turn.)]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_LIFEWEAVER))
	c:RegisterEffect(e1)
	--[[If a "Lifeweaver" Time Leap Monster(s) returns to the Extra Deck (except during the Damage Step): You can draw 1 card, then inflict 500 damage to your opponent.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_DRAW|CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetCondition(aux.EventGroupCond(s.cfilter))
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
--FILTERS E2
function s.cfilter(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsMonster(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_LIFEWEAVER)
end
--E2
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end