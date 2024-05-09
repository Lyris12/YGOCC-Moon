--created by LeonDuvall, coded by Lyris, fixed by XGlitchy30
--Praise the Immortal Sun
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id,CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_MACRO_COSMOS)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT(true)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetRelevantTimings()
	e2:SetFunctions(s.setcon,aux.ToDeckSelfCost,s.settg,s.setop)
	c:RegisterEffect(e2)
end
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	for _,code in ipairs{CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_MACRO_COSMOS} do
		if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,code) then return false end
	end
	return rp==1-tp and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToChain(ev) then Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then Duel.Destroy(eg,REASON_EFFECT) end
end
function s.setcon(e)
	return Duel.GetTurnCount()~=e:GetHandler():GetTurnID()
end
function s.setfilter(c)
	return c:IsST() and c:Mentions(CARD_HELIOS_THE_PRIMORDIAL_SUN) and not c:IsCode(id) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.setfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
