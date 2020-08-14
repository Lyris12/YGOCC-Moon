--created by ZEN, coded by TaxingCorn117
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cid.thcost)
	e1:SetLabel(0)
	e1:SetTarget(cid.thtg)
	e1:SetOperation(cid.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0x3c0)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(cid.con)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.op)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_SUMMON)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(cid.con2)
	e3:SetTarget(cid.tg2)
	e3:SetOperation(cid.op)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e5)
end
function cid.cfilter(c)
	return c:IsSetCard(0x52f) and c:IsAbleToRemove() 
		and Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c:GetOriginalCode())
end
function cid.thfilter(c,code)
	return c:IsSetCard(0x52f) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:GetCode()~=code and c:IsAbleToHand()
end
function cid.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_DECK,0,1,nil)
	end
	local rg=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	e:SetLabelObject(rg)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	e1:SetCondition(cid.adcon)
	e1:SetOperation(cid.adop)
	e1:SetLabel(0)
	rg:RegisterEffect(e1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function cid.adcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function cid.adop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	e:GetHandler():SetTurnCounter(ct+1)
	if ct==1 then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,e:GetHandler())
	else e:SetLabel(1) end
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabelObject():GetCode()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,code)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cid.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(1-tp)-Duel.GetLP(tp)>=1500 and not Duel.CheckEvent(EVENT_CHAINING)
end
function cid.filter1(c)
	return c:IsType(TYPE_COUNTER) and c:IsSetCard(0x52f) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and c:CheckActivateEffect(false,true,false)~=nil
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and (chkc:IsLocation(LOCATION_REMOVED) or chkc:IsControler(tp)) and cid.filter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(math.floor(id/100),3))
	local g=Duel.SelectTarget(tp,cid.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function cid.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(1-tp)-Duel.GetLP(tp)>=1500
end
function cid.filter2(c,e,tp,eg,ep,ev,re,r,rp)
	if c:IsType(TYPE_COUNTER) and c:IsSetCard(0x52f) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) then
		if c:CheckActivateEffect(false,true,false)~=nil then return true end
		local te=c:GetActivateEffect()
		if te:GetCode()~=EVENT_CHAINING then return false end
		local con=te:GetCondition()
		if con and not con(e,tp,eg,ep,ev,re,r,rp) then return false end
		local tg=te:GetTarget()
		if tg and not tg(e,tp,eg,ep,ev,re,r,rp,0) then return false end
		return true
	else return false end
end
function cid.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and (chkc:IsLocation(LOCATION_REMOVED) or chkc:IsControler(tp)) and cid.filter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(math.floor(id/100),3))
	local g=Duel.SelectTarget(tp,cid.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	local tc=g:GetFirst()
	local te,ceg,cep,cev,cre,cr,crp
	local fchain=cid.filter1(tc)
	if fchain then
		te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	else
		te=tc:GetActivateEffect()
	end
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then
		if fchain then
			tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
		else
			tg(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
end
