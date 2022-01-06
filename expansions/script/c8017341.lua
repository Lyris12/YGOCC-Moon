--Pandemoniumplaza
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(cid.desreptg)
	e2:SetValue(cid.desrepval)
	e2:SetOperation(cid.desrepop)
	c:RegisterEffect(e2)
	--set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(cid.settg)
	e3:SetOperation(cid.setop)
	c:RegisterEffect(e3)
end
--ACTIVATE
function cid.filter(c,sg)
	if not c:IsType(TYPE_PANDEMONIUM) or not c:IsType(TYPE_MONSTER) or not c:IsAbleToHand() or #sg<=0 then return false end
	local lscale,rscale,ct,check=c:GetLeftScale(),c:GetRightScale(),0,false
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local tc=sg:GetFirst()
	while tc do
		local lv=tc:GetLevel()
		if lv>lscale and lv<rscale then
			ct=ct+1
		end
		tc=sg:GetNext()
	end
	if ct==#sg then check=true end
	return check
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:GetLevel()>0
end
----------
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local field=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local g=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_DECK,0,nil,field)
	if Duel.GetFlagEffect(tp,id)<=0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local field2=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_DECK,0,1,1,nil,field2):GetFirst()
		if tc then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
--DESTROY REPLACE
function cid.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:GetFlagEffect(726)>0
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function cid.dryfilter(c,e)
	return c:IsType(TYPE_PANDEMONIUM) and c:IsType(TYPE_MONSTER)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
---------
function cid.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(cid.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(cid.dryfilter,tp,LOCATION_DECK,0,1,nil,e)
	end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local sg=Duel.SelectMatchingCard(tp,cid.dryfilter,tp,LOCATION_DECK,0,1,1,nil,e)
		e:SetLabelObject(sg:GetFirst())
		sg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function cid.desrepval(e,c)
	return cid.repfilter(c,e:GetHandlerPlayer())
end
function cid.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
--SET
function cid.setfilter(c,e,tp)
	return c:IsFaceup() and c:GetFlagEffect(726)>0 and aux.PandSSetCon(c,nil,c:GetLocation())(nil,e,tp)
end
------------
function cid.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and cid.setfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(cid.setfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler())
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	Duel.SelectTarget(tp,cid.setfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
end
function cid.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and aux.PandSSetCon(tc,nil,tc:GetLocation())(nil,e,tp,eg,ep,ev,re,r,rp) then
		aux.PandSSet(tc,REASON_EFFECT,aux.GetOriginalPandemoniumType(tc))(e,tp,eg,ep,ev,re,r,rp)
		if tc:IsFacedown() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
			local rc=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
			local rct=rc:GetFirst()
			if #rc>0 then
				Duel.HintSelection(rc)
				Duel.ConfirmCards(1-tp,rc)
				if aux.Pandemoniums[rct] and aux.GetOriginalPandemoniumType(rct)~=0 then
					local actcon=rct:GetActivateEffect():GetCondition()
					if actcon(rct:GetActivateEffect(),tp,eg,ep,ev,re,r,rp) then
						if rct:GetActivateEffect():GetCost() then
							if rct:GetActivateEffect():GetCost()(e,tp,eg,ep,ev,re,r,rp,0) then
								rct:GetActivateEffect():GetCost()(e,tp,eg,ep,ev,re,r,rp,1)
							else
								return
							end
						end
						Duel.ChangePosition(rct,POS_FACEUP)
						rct:RegisterFlagEffect(726,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE,1)
					end
				else
					Duel.Destroy(rct,REASON_EFFECT)
				end
			end
		end
	end
end	