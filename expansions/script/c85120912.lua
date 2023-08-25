--created by LeonDuvall, coded by Lyris
--Alignment of the Cosmos
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,54493213,30241314)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetValue(s.zones)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetCondition(aux.exccon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsLocation(LOCATION_SZONE) then return 0xff end
	local zone=0
	for i=0,4 do
		if Duel.GetFieldCard(tp,LOCATION_MZONE,4-1<<i) or Duel.GetFieldCard(tp,LOCATION_SZONE,4-1<<i) then
			zone=zone|1<<i
		end
	end
	return zone
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(54493213)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.filter(c,tc)
	return tc:GetColumnGroup():IsContains(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsLocation(LOCATION_HAND)
		or Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil,c) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Destroy(c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp):Select(tp,1,1,nil),REASON_EFFECT)
	end
end
function s.sfilter(c)
	return (aux.IsCodeListed(c,54493213) or aux.IsCodeListed(c,30241314) or c:IsCode(80887952,30241314,38430673))
		and c:IsSSetable() and not c:IsCode(id)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_DECK)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then Duel.SSet(tp,tc) end
end
