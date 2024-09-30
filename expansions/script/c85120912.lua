--created by LeonDuvall, coded by Lyris, fixed by XGlitchy30
--Alignment of the Cosmos
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id,CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_MACRO_COSMOS)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetRelevantTimings()
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetValue(s.zones)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetRelevantTimings()
	e2:SetFunctions(s.setcon,nil,s.settg,s.setop)
	c:RegisterEffect(e2)
end
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsInBackrow() then return 0xff end
	local zone=0
	for i=0,4 do
		if Duel.GetFieldCard(1-tp,LOCATION_MZONE,i) or Duel.GetFieldCard(1-tp,LOCATION_SZONE,i) then
			local val=Duel.GetColumnZoneFromSequence(i,LOCATION_ONFIELD,LOCATION_SZONE)>>24
			zone=zone|val
		end
	end
	return zone
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_HELIOS_THE_PRIMORDIAL_SUN)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.filter(c,tc)
	return tc:GetColumnGroup():IsContains(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsLocation(LOCATION_HAND) or Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil,c) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp),1,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.HintMessage(tp,HINTMSG_DESTROY)
		local g=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp):Select(tp,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.setcon(e)
	return Duel.GetTurnCount()~=e:GetHandler():GetTurnID()
end
function s.sfilter(c)
	return c:Mentions(CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_MACRO_COSMOS) and c:IsSSetable() and not c:IsCode(id)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local tc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if tc then
			Duel.SSet(tp,tc)
		end
	end
end
