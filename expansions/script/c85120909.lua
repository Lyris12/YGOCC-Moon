--created by LeonDuvall, coded by Lyris
--Approaching the Event Horizon
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,30241314,54493213)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.con(e,tp)
	for _,i in ipairs{30241314,54493213} do
		if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil,i) then return false end
	end
	return true
end
function s.tg(e,tp,eg,ep,ev,r,er,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.op(e,tp)
	if Duel.Damage(1-tp,300,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Destroy(Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP),REASON_EFFECT)
	end
end
