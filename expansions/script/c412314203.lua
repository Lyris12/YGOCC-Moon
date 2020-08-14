--created by Jake, coded by Glitchy
local cid,id=GetID()
function cid.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	local pe1=Effect.CreateEffect(c)
	pe1:SetCategory(CATEGORY_HANDES+CATEGORY_DESTROY)
	pe1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCode(EVENT_PHASE+PHASE_END)
	pe1:SetCountLimit(1)
	pe1:SetCondition(cid.dccon)
	pe1:SetTarget(cid.dctg)
	pe1:SetOperation(cid.dcop)
	c:RegisterEffect(pe1)
	local pe2=Effect.CreateEffect(c)
	pe2:SetType(EFFECT_TYPE_QUICK_O)
	pe2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	pe2:SetCode(EVENT_FREE_CHAIN)
	pe2:SetRange(LOCATION_PZONE)
	pe2:SetCountLimit(1)
	pe2:SetTarget(cid.pttg)
	pe2:SetOperation(cid.ptop)
	c:RegisterEffect(pe2)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(cid.thtg)
	e1:SetOperation(cid.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(cid.spcost)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(cid.pzcon)
	e3:SetTarget(cid.pztg)
	e3:SetOperation(cid.pzop)
	c:RegisterEffect(e3)
end
function cid.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x613)
end
function cid.thfilter(c)
	local m=_G["c"..c:GetCode()]
	if not m then return false end
	local list=m.material_setcode
	return c:IsSetCard(0x613) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and list and list==0x613
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x613) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.checkdiscard(c)
	return c:IsDiscardable(REASON_EFFECT)
end
function cid.dccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function cid.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g<=0 or not g:IsExists(cid.checkdiscard,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	end
end
function cid.dcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	if #g>0 and g:IsExists(cid.checkdiscard,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local dc=g:FilterSelect(tp,cid.checkdiscard,1,1,nil)
		Duel.SendtoGrave(dc:GetFirst(),REASON_EFFECT+REASON_DISCARD)
	else 
		Duel.Destroy(c,REASON_EFFECT) 
	end
end
function cid.pttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cid.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function cid.ptop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	end
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function cid.pzcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x4040)==0x4040 and re:GetHandler():IsSetCard(0x613) and re:GetHandler()~=e:GetHandler()
		and e:GetHandler():GetPreviousControler()==tp
end
function cid.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
function cid.pzop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end