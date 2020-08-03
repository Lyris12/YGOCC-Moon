--False Reailty Wrath Bringer Makolo"
local s,id=GetID()
function s.initial_effect(c)
		--search
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_HAND)
		e1:SetCountLimit(1,id+500)
		e1:SetCost(s.thcost)
		e1:SetTarget(s.thtg)
		e1:SetOperation(s.thop)
		c:RegisterEffect(e1)	
end
	function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,REASON_COST)
end
	function s.thfilter1(c)
	return c:IsCode(195208413) and c:IsAbleToHand()
end
	function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
	function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetFirstMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,nil)
	if tg then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end
	function s.cfilter(c)
	return c:IsSetCard(0x83e) and not c:IsPublic()
end
	function s.costo(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
	function s.torgo(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_ONFIELD,PLAYER_NONE,0)+Duel.GetLocationCount(1-tp,LOCATION_ONFIELD,PLAYER_NONE,0)
	if Duel.CheckLocation(tp,LOCATION_ONFIELD,11) and Duel.CheckLocation(1-tp,LOCATION_MZONE,6) then ft=ft+1 end
	if Duel.CheckLocation(tp,LOCATION_MZONE,6) and Duel.CheckLocation(1-tp,LOCATION_MZONE,5) then ft=ft+1 end
	if chk==0 then return ft>0 end
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0)
	e:SetLabel(seq)
	Duel.Hint(HINT_ZONE,tp,seq)





if chk==0 then return true end