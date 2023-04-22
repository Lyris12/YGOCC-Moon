--Extra Hyperdrive
--Extra Iperdrive
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Decrease the Energy of your Engaged monster by the number of cards in your Extra Deck; send 1 monster from your Extra Deck to the GY.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SHOPT(true)
	e1:SetCost(aux.UpdateEnergyCost(s.enct))
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; increase the Energy of your Engaged monster by the number of cards in your opponent's Extra Deck.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT(true)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.entg)
	e2:SetOperation(s.enop)
	c:RegisterEffect(e2)
end
function s.enct(ec,e,tp)
	return -Duel.GetExtraDeckCount(tp)
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

function s.entg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ec=Duel.GetEngagedCard(tp)
		local ct=Duel.GetExtraDeckCount(1-tp)
		return ec and ct>0 and ec:IsCanUpdateEnergy(ct,tp,REASON_EFFECT)
	end
end
function s.enop(e,tp,eg,ep,ev,re,r,rp)
	local ec=Duel.GetEngagedCard(tp)
	local ct=Duel.GetExtraDeckCount(1-tp)
	if ec and ct>0 then
		ec:UpdateEnergy(ct,tp,REASON_EFFECT,true,e:GetHandler())
	end
end