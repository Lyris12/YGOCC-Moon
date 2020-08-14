--created by Jake, coded by Glitchy
local cid,id=GetID()
function cid.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	local pe1=Effect.CreateEffect(c)
	pe1:SetType(EFFECT_TYPE_FIELD)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	pe1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	pe1:SetTargetRange(1,0)
	pe1:SetTarget(cid.splimit)
	c:RegisterEffect(pe1)
	local pe2=Effect.CreateEffect(c)
	pe2:SetCategory(CATEGORY_RECOVER)
	pe2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	pe2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	pe2:SetRange(LOCATION_PZONE)
	pe2:SetCode(EVENT_DISCARD)
	pe2:SetCondition(cid.lpcon)
	pe2:SetTarget(cid.lptg)
	pe2:SetOperation(cid.lpop)
	c:RegisterEffect(pe2)
	local pe3=Effect.CreateEffect(c)
	pe3:SetType(EFFECT_TYPE_QUICK_O)
	pe3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	pe3:SetCode(EVENT_FREE_CHAIN)
	pe3:SetRange(LOCATION_PZONE)
	pe3:SetCountLimit(1)
	pe3:SetTarget(cid.pttg)
	pe3:SetOperation(cid.ptop)
	c:RegisterEffect(pe3)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(cid.thtg)
	e1:SetOperation(cid.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
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
function cid.cfilter(c,tp)
	return c:GetPreviousControler()==tp and c:IsSetCard(0x613)
end
function cid.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x613)
end
function cid.thfilter(c)
	return c:IsSetCard(0x613) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(id)
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x613) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsRace(RACE_WARRIOR) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function cid.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.cfilter,1,nil,tp)
end
function cid.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(300)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,300)
end
function cid.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Recover(p,d,REASON_EFFECT)
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
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
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
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(cid.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(cid.spfilter),tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	if g:GetFirst():GetOriginalLevel()>0 then
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetOriginalLevel()*300)
	end
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local lv=tc:GetOriginalLevel()
			if lv<0 then lv=0 end
			Duel.Recover(tp,lv*300,REASON_EFFECT)
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