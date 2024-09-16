--created by Slick, coded by Lyris
--Kronologistics Copper Dragon
local s,id,o = GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,10)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.ncon)
	e1:SetOperation(s.nop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.icon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(s.ccon)
	e3:SetOperation(s.reg)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_CHAIN_SOLVED)
	c:RegisterEffect(e4)
	c:DriveEffect(-4,1100,CATEGORY_DESTROY,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,nil,nil,s.destg,s.desop)
	c:DriveEffect(-8,1118,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,nil,nil,s.sptg,s.spop)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e5:SetDescription(1131)
	e5:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e5:SetCondition(s.discon)
	e5:SetTarget(s.distg)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BE_MATERIAL)
	e6:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e6:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetDescription(1104)
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetCondition(s.thcon)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
end
function s.ncon(e)
	return e:GetHandler():IsEnergyBelow(7)
end
function s.icon(e,tp,eg,ep,ev,re,r,rp)
	return s.ncon(e) and not Duel.IsChainSolving()
end
function s.ccon(e,tp,eg,ep,ev,re,r,rp)
	return s.ncon(e) and Duel.IsChainSolving()
end
function s.reg(_,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
function s.nop(e,tp)
	local n=1
	if e:GetCode()==EVENT_CHAIN_SOLVING then
		n=Duel.GetFlagEffect(tp,id)
		Duel.ResetFlagEffect(tp,id)
	end
	e:GetHandler():UpdateEnergy(n,tp,REASON_EFFECT)
end
function s.dfilter(c)
	return c:GetSequence()<5
end
function s.destg(e,tp,_,_,_,_,_,_,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	local ct,p,loc=1,0,0
	if Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_SZONE,0,1,nil) then ct,p,loc=2,tp,LOCATION_ONFIELD end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP),ct,p,loc)
end
function s.desop(e,tp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_SZONE,0,1,nil)) then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.Destroy(Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_ONFIELD,0,1,1,nil),REASON_EFFECT)
end
function s.filter(c,e,tp)
   return c:IsType(TYPE_DRIVE+TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,_,_,_,_,_,_,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp))
end
function s.spop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
function s.discon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_DRIVE)
end
function s.distg(e,tp,_,_,_,_,_,_,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.disop(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e,false) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		Duel.BreakEffect()
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.thcon(e)
	return e:GetHandler():IsReason(REASON_SYNCHRO+REASON_TIMELEAP)
end
function s.thtg(e,tp,_,_,_,_,_,_,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then Duel.SendtoHand(c,REASON_EFFECT) Duel.ConfirmCards(1-tp,c) end
end
