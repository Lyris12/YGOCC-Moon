--The Invocation of Arcana
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--retrieve
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(cid.econ)
	e2:SetTarget(cid.etg)
	e2:SetOperation(cid.eop)
	c:RegisterEffect(e2)
	--retrieve 2
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id+200)
	e3:SetCondition(cid.thcon)
	e3:SetOperation(cid.thop)
	c:RegisterEffect(e3)
end
--ACTIVATE
function cid.cfilter(c)
	return c:IsSetCard(0x5478) and c:IsAbleToHand()
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+(RESETS_STANDARD-RESET_TOGRAVE-RESET_LEAVE)+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+(RESETS_STANDARD-RESET_TOGRAVE-RESET_LEAVE)+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,0)
	end
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--RETRIEVE
function cid.econ(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(id)
	return tid and tid~=Duel.GetTurnCount() and Duel.GetTurnPlayer()==tp
end
function cid.etg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function cid.eop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (c:IsRelateToEffect(e) or e:GetLabel()==100) and c:IsAbleToHand() then
		if e:GetLabel()==100 then Duel.Hint(HINT_CARD,tp,id) Duel.Hint(HINT_CARD,1-tp,id) end
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,Group.FromCards(c))
	end
end
--RETRIEVE 2
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:GetHandler():IsSetCard(0x5478) and e:GetHandler():IsLocation(LOCATION_REMOVED)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetLabel(100)
	e1:SetCondition(cid.econ)
	e1:SetOperation(cid.eop)
	if Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,Duel.GetTurnCount())
	else
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,0)
	end
	Duel.RegisterEffect(e1,tp)
end