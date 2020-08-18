--created by Hoshi, coded by NeoBlackStar
local cid,id=GetID()
function cid.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	aux.AddCodeList(c,id-15)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(cid.negcon)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.distg)
	e1:SetOperation(cid.disop)
	c:RegisterEffect(e1)
	--Alvis Leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(cid.cfilter,1,nil,tp) and Duel.GetTurnPlayer()==1-tp end)
	e2:SetTarget(cid.eqtg)
	e2:SetOperation(cid.eqop)
	c:RegisterEffect(e2)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_EQUIP)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetCondition(function(e) return e:GetHandler():GetEquipTarget():IsCode(id-15) end)
	e0:SetValue(function(e,te) return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and e:GetHandlerPlayer()~=te:GetOwnerPlayer() end)
	c:RegisterEffect(e0)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function cid.cfilter(c,tp)
	return c:GetPreviousCodeOnField()==id-15 and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousControler()==tp
end
function cid.nfilter(c)
	return c:IsCode(id-15)
end
function cid.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.nfilter,tp,LOCATION_MZONE,0,1,nil) and tp~=ep and Duel.IsChainNegatable(ev)
end
--Alvis Leaves the Field
function cid.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(cid.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and not Duel.IsExistingMatchingCard(cid.nfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
	if e:GetHandler():IsHasEffect(id-1) then Duel.SetChainLimit(function(e,rpr,p) return rpr==p end) end
end
function cid.eqfilter(c,tp)
	return c:IsSetCard(0xcda) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function cid.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if not sc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	if not tc or not Duel.Equip(tp,sc,tc) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(function(ef,cc) return cc==tc end)
	sc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(id-15)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
end
--Handtrap eff
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
end
