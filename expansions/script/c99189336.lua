--Arcarum I - IL BAGATTO
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--apply effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetLabelObject(e1)
	e2:SetCondition(cid.econ)
	e2:SetTarget(cid.etg)
	e2:SetOperation(cid.eop)
	c:RegisterEffect(e2)
end
--filters
function cid.cfilter(c,mode)
	if not mode then return false end
	local ableto
	if mode==0 then
		ableto=c:IsAbleToRemoveAsCost()
	else
		ableto=c:IsAbleToHand()
	end
	return c:IsSetCard(0x5477) and c:IsType(TYPE_SPELL) and ableto and not c:IsCode(id)
end
--Activate
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_GRAVE,0,1,nil,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,0)
	if Duel.Remove(rg,POS_FACEUP,REASON_COST)~=0 then
		local og=Duel.GetOperatedGroup():GetFirst()
		if og:IsType(TYPE_SPELL) and og:IsSetCard(0x5477) then
			local ae=og:GetActivateEffect()
			e:SetLabelObject(ae)
		end
	end
	if Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+(RESETS_STANDARD-RESET_TOGRAVE-RESET_LEAVE)+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+(RESETS_STANDARD-RESET_TOGRAVE-RESET_LEAVE)+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,0)
	end
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_DECK,0,1,nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_DECK,0,1,1,nil,1)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--apply effect
function cid.econ(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(id)
	return tid and tid~=Duel.GetTurnCount() and Duel.GetTurnPlayer()==tp
end
function cid.etg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ae=e:GetLabelObject():GetLabelObject()
	local ftg=ae:GetTarget()
	if chk==0 then return ae and (not ftg or ftg(e,tp,eg,ep,ev,re,r,rp,chk)) end
	if ae:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else 
		e:SetProperty(0) 
	end
	if ftg then
		ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function cid.eop(e,tp,eg,ep,ev,re,r,rp)
	local ae=e:GetLabelObject():GetLabelObject()
	if not ae then return end
	local fop=ae:GetOperation()
	fop(e,tp,eg,ep,ev,re,r,rp)
end