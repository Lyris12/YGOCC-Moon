--Metalurgos Conduction
--Conduzione Metalurgo
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--[[Face-up "Metalurgos" cards you control cannot be targeted by your opponent's card effects, except "Metalurgos Conduction".]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.prtg)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--[[If a "Metalurgos" Drive Monster(s) is sent from the hand to the GY due to having 0 Energy (except during the Damage Step):
	You can target 1 "Metalurgos" Drive Monster in your GY; add it to your hand, and if you do, Engage it.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetCondition(aux.EventGroupCond(s.cfilter))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--[[If this card is destroyed by the effect of a "Metalurgos" card: You can add 1 "Metalurgos" card from your Deck to your hand, except "Metalurgos Conduction".]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.thcon)
	e3:SetTarget(aux.SearchTarget(s.scfilter))
	e3:SetOperation(aux.SearchOperation(s.scfilter))
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		s.triggering_setcode={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	local rc=re:GetHandler()
	if rc:IsRelateToChain(ev) then
		if rc:IsSetCard(ARCHE_METALURGOS) then
			s.triggering_setcode[cid]=true
			return
		end
	else
		if rc:IsPreviousSetCard(ARCHE_METALURGOS) then
			s.triggering_setcode[cid]=true
			return
		end
	end
	s.triggering_setcode[cid]=false
end
--E1
function s.prtg(e,c)
	return c:IsSetCard(ARCHE_METALURGOS) and not c:IsCode(id)
end

--FILTERS E2
function s.cfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsSetCard(ARCHE_METALURGOS) and c:DueToHavingZeroEnergy()
end
function s.thfilter(c,tp)
	return c:IsMonster(TYPE_DRIVE) and c:IsSetCard(ARCHE_METALURGOS) and c:IsAbleToHand() and c:IsCanEngage(tp)
end
--E2
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.SearchAndEngage(tc,e,tp,true)
	end
end

--FILTERS E3
function s.scfilter(c)
	return c:IsSetCard(ARCHE_METALURGOS) and not c:IsCode(id)
end
--E3
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not re or not e:GetHandler():IsReason(REASON_EFFECT) then return false end
	local rc=re:GetHandler()
	if re:IsActivated() then
		local ch=Duel.GetCurrentChain()
		local cid=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID)
		return s.triggering_setcode[cid]==true
	else
		return rc:IsSetCard(ARCHE_METALURGOS)
	end
end