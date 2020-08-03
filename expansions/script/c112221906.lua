--created by Hoshi, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	aux.AddCodeList(c,id-6)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1109)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(cid.cfilter,1,nil,tp) end)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetDescription(1104)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetLabelObject(c)
	e3:SetTarget(cid.thtg)
	e3:SetOperation(cid.thop)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(cid.tg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	local qe=e3:Clone()
	qe:SetType(EFFECT_TYPE_QUICK_O)
	qe:SetCode(EVENT_FREE_CHAIN)
	qe:SetCondition(function(e,tp) return Duel.IsPlayerAffectedByEffect(tp,id+108) end)
	local e5=e4:Clone()
	e5:SetLabelObject(qe)
	c:RegisterEffect(e5)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function cid.filter(c)
	return c:IsCode(id-6) and (c:IsLocation(LOCATION_DECK) and c:IsAbleToHand() or (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToDeck())
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.filter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil):GetFirst()
	if tg and tg:IsLocation(LOCATION_DECK) then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	elseif tg then Duel.SendtoDeck(tg,nil,2,REASON_EFFECT) end
end
function cid.cfilter(c,tp)
	return c:GetPreviousCodeOnField()==id-6 and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousControler()==tp
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
	if e:GetHandler():IsHasEffect(id+8) then Duel.SetChainLimit(function(e,rpr,p) return rpr==p end) end
end
function cid.spfilter(c,e,tp)
	return c:IsCode(id-6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if not Duel.Equip(tp,c,tc) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(function(ef,cc) return tc==cc end)
		c:RegisterEffect(e1)
	end
end
function cid.tg(e,c)
	return c==e:GetHandler():GetEquipTarget() and c:IsCode(id-6)
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	local c=e:GetLabelObject()
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil),1,0,0)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
