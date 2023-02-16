--Gardrenial Spirit - Bloom
local ref,id=GetID()
Duel.LoadScript("GardrenialCommons.lua")
function ref.initial_effect(c)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.thtg)
	e1:SetOperation(ref.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Return
	local e3=Gardrenial.CreateDualityEffect(c,RACE_INSECT)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(ref.rettg)
	e3:SetOperation(ref.retop)
	c:RegisterEffect(e3)
end

--Search
function ref.grgfilter(g)
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK)
end
function ref.grfilter(c) return Gardrenial.Is(c) and c:IsAbleToGrave() end
function ref.thfilter(c) return Gardrenial.Is(c) and c:IsAbleToHand() end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(ref.grfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		return g:CheckSubGroup(ref.grgfilter,2,2)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function ref.thop(e,tp)
	local ag=Duel.GetMatchingGroup(ref.grfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=ag:SelectSubGroup(tp,ref.grgfilter,false,2,2)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.BreakEffect()
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g2)
	end
end

--Return
function ref.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_GRAVE)
end
function ref.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
