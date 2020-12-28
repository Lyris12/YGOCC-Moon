--Engrav, Forgotten City
--Script by XGlitchy30
function c36541449.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c36541449.eqop)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(c36541449.reptg)
	e2:SetOperation(c36541449.repop)
	c:RegisterEffect(e2)
	--to deck
	local e3=Effect.CreateEffect(c)
	e3:GLString(1)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1)
	e3:SetTarget(c36541449.tdtg)
	e3:SetOperation(c36541449.tdop)
	c:RegisterEffect(e3)
	--gain effect
	local e4x=Effect.CreateEffect(c)
	e4x:GLString(2)
	e4x:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4x:SetType(EFFECT_TYPE_IGNITION)
	e4x:SetRange(LOCATION_SZONE)
	e4x:SetTarget(c36541449.sptg)
	e4x:SetOperation(c36541449.spop)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE+LOCATION_SZONE,0)
	e4:SetCondition(c36541449.effectcon)
	e4:SetTarget(c36541449.effecttg)
	e4:SetLabelObject(e4x)
	c:RegisterEffect(e4)
end
--filters
function c36541449.eqfilter(c,tp)
	return c:IsFaceup() and c:CheckUniqueOnField(tp) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function c36541449.eqtgfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(c36541449.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
end
function c36541449.eqlimit(e,c)
	return e:GetLabelObject()==c
end
--values
function c36541449.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function c36541449.retfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and not c:IsReason(REASON_DESTROY) and c:IsAbleToDeck()
end
--Activate
function c36541449.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not Duel.IsExistingMatchingCard(c36541449.eqtgfilter,tp,LOCATION_MZONE,0,1,nil,tp) or not Duel.SelectYesNo(tp,aux.Stringid(36541449,0)) then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c36541449.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	if not tc1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g2=Duel.SelectMatchingCard(tp,c36541449.eqtgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc2=g2:GetFirst()
	if not tc2 or not tc2:IsFaceup() then return end
	if tc1:IsLocation(LOCATION_GRAVE) and Duel.Equip(tp,tc1,tc2) then
		--Add Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c36541449.eqlimit)
		e1:SetLabelObject(tc2)
		tc1:RegisterEffect(e1)
	else 
		Duel.SendtoGrave(tc1,REASON_EFFECT) 
	end
end
--to hand
function c36541449.repfilter(c)
	return c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function c36541449.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE) and e:GetHandler():IsAbleToHand() and Duel.IsExistingMatchingCard(c36541449.repfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function c36541449.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c36541449.repfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)~=0 then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT+REASON_REPLACE)
	end
end
--shuffle
function c36541449.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c36541449.retfilter,1,nil) end
	local g=eg:Filter(c36541449.retfilter,nil)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function c36541449.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c36541449.retfilter,nil)
	if #sg<=0 then return end
	Duel.HintSelection(sg)
	Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
end
--effect gain
function c36541449.effectcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
function c36541449.effecttg(e,c)
	return c:IsCode(36541443,36541444,36541445,36541446,36541447,36541448)
end
function c36541449.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c36541449.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end