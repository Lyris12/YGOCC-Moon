--Metalurgos Charging Device
--Dispositivo di Ricarica Metalurgo
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--[[Face-up "Metalurgos" monsters you control cannot be destroyed by your opponent's card effects.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_METALURGOS))
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--[["Metalurgos" monsters you control gain 100 ATK/DEF x the current Energy of your Engaged "Metalurgos" Drive Monster.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkdefcon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_METALURGOS))
	e2:SetValue(s.atkdef)
	c:RegisterEffect(e2)
	e2:UpdateDefenseClone(c)
	--[[During the Main Phase: You can target 1 face-up monster you control; increase or reduce your Engaged "Metalurgos" Drive Monster's Energy by the target's Level.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:HOPT()
	e3:SetTarget(s.entg)
	e3:SetOperation(s.enop)
	c:RegisterEffect(e3)
	--[[If this card is destroyed by the effect of a "Metalurgos" card: You can target 1 "Metalurgos" monster in your GY; Special Summon it.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED)
	e4:HOPT()
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
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

--E2
function s.atkdefcon(e)
	local ec=Duel.GetEngagedCard(e:GetHandlerPlayer())
	return ec and ec:IsMonster(TYPE_DRIVE) and ec:IsSetCard(ARCHE_METALURGOS)
end
function s.atkdef(e,c)
	local ec=Duel.GetEngagedCard(e:GetHandlerPlayer())
	if not ec then return 0 end
	return ec:GetEnergy()*100
end

--FILTERS E3
function s.cfilter(c,ec,tp)
	return c:IsFaceup() and c:HasLevel() and ec:IsCanIncreaseOrDecreaseEnergy(c:GetLevel(),tp,REASON_EFFECT)
end
--E3
function s.entg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ec=Duel.GetEngagedCard(tp)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc,ec,tp) end
	if chk==0 then
		return ec and ec:IsMonster(TYPE_DRIVE) and ec:IsSetCard(ARCHE_METALURGOS) and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,ec,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,ec,tp)
end
function s.enop(e,tp,eg,ep,ev,re,r,rp)
	local ec=Duel.GetEngagedCard(tp)
	if not (ec and ec:IsMonster(TYPE_DRIVE) and ec:IsSetCard(ARCHE_METALURGOS)) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and s.cfilter(tc,ec,tp) then
		ec:IncreaseOrDecreaseEnergy(tc:GetLevel(),tp,REASON_EFFECT,true,e:GetHandler(),e)
	end
end

--FILTERS E4
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_METALURGOS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E4
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
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
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end