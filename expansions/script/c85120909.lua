--created by LeonDuvall, coded by Lyris, fixed by XGlitchy30
--Approaching the Event Horizon
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MACRO_COSMOS,CARD_HELIOS_THE_PRIMORDIAL_SUN)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCategory(CATEGORY_DAMAGE|CATEGORY_DESTROY)
	e1:SetRelevantTimings()
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.con(e,tp)
	for _,i in ipairs{CARD_MACRO_COSMOS,CARD_HELIOS_THE_PRIMORDIAL_SUN} do
		if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil,i) then return false end
	end
	return true
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,LOCATION_ONFIELD)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Damage(1-tp,300,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
